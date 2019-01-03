---
title:  "Distinguishing Cats from Dogs with Deeplearning4j, Kotlin and the VGG16 model"
banner: "/images/using-deeplearning4j-to-distinguish-between-cats-and-dogs/banner.png"
description: "Showing how to use Kotlin, deeplearning4j and the famous VGG16 model to distinguish between cat and dog pictures for learning purpose."
date:   2017-10-29 19:25:00 +0900
---

The first task in the [fast.ai](http://www.fast.ai/) course is to enter a compitition on [Kaggle](https://www.kaggle.com/c/dogs-vs-cats).
The competitions goal is to successfully distinguish between cat and dog images.
I didn't go so far to submit my result to Kaggle, but instead, I gave myself the challenge to solve the problem within a completely different technology stack rather than using the one from the course.

# Deeplearning4j and Kotlin

The machine learning field heavily uses Python, but for some reason I never feel 100% comfortable when writing Python code.
Personally, I tend to like Ruby for simple stuff in a small team and for everything else I prefer strongly typed languages such as C++ or Java.

With Java being [the second popular choice](https://www.siliconrepublic.com/advice/machine-learning-programming-language) among data scientists, the [deeplearning4j](https://deeplearning4j.org/) library was the most natural choice for me.
Backed up by [Skymind](https://skymind.ai/), a successful startup from San Francisco, it has enough support to be used worry free.
It is also the [only choice](https://en.wikipedia.org/wiki/Comparison_of_deep_learning_software) in Java as for now.

Another movement in the Java world that is currently getting momentum is [Kotlin](https://kotlinlang.org/).
It is a language that compiles to JVM code and thus runs wherever there is a Java Virtual Machine.
Or in simpler terms, wherever you have installed Java.

Kotlin was desinged to be fully interoperable with Java and its libraries.
It provides many shortcuts at language level for concepts and patterns that emerged from the Java community over the years.
Also, Kotlins standard library provides many functions that introduce coding concepts similar to what you can see in Ruby.

So all together, with Kotlin you get a language that is statically typed, can use almost every Java library out there and produces easily understandable code naturally.
This is just perfect for this project.

![The people from JetBrains, the company that is famous for the IntelliJ IDE, are the minds behind the Kotlin language](/images/using-deeplearning4j-to-distinguish-between-cats-and-dogs/kotlin.png)

# Teaching about Cats and Dogs

In the course, it is suggested to adjust a thing called the VGG16 model.
The VGG16 model is a 16 layer neural network, that was designed to perform well in the image recognition field.
On default it takes a picture as its input and outputs values for 1000 labels that were defined by [Imagenet](https://www.image-net.org/).
These values express the likelihood of what the model thinks it sees on the image.

![Visualization of the VGG16 model](/images/using-deeplearning4j-to-distinguish-between-cats-and-dogs/vgg16.png)

The proposed adjusting process is to make the final layer output only 2 labels, a `cat` and a `dog` label, rather than the 1000 ones from Imagenet.

Since this was my first experiment with deeplearning4j I opted for an even simpler approach that was also briefly mentioned.
Instead of adjusting the model itself, you could just add an additional layer that is trained to map the 1000 Imagenet labels to the 2 new `cat` and `dog` labels.
This sacrifices a few percent of accuracy but is easier to implement.
I am doing this just for learning purpose anyway.

In any case, the network has to be fed with a lot of training images that teach the difference between cats and dogs.
The fast.ai course provides the ones from Kaggle neatly arranged in a [zip file](http://files.fast.ai/files/dogscats.zip).

## Preprocessing

So the first task is to find out all output labels of the training images with the VGG16 model as they can be used as training input for the new model.
Deeplearning4j makes this easy, as it provides a (pretrained) VGG16 model by its [Model Zoo](https://deeplearning4j.org/model-zoo).

The output labels of a training image can be obtained with a few lines:

```kotlin
val model = VGG16().initPretrained(PretrainedType.IMAGENET) as ComputationGraph
val image = FileInputStream("input.png")
val input = NativeImageLoader(224, 224, 3).asMatrix(image).also { VGG16ImagePreProcessor().transform(it) }
val output = model.outputSingle(input)
```

`output` now holds the accuracy values for each of the 1000 Imagenet labels.
From the training data, we also know if these labels refer to a cat or a dog.

## Teaching the relations between the Labels and Cats/Dogs

As we now have input Labels with the answer of being either a cat or a dog, it is easy to train the new model that should learn about this relation.
It turns out that it is enough to just use the architecture from [the very first tutorial](https://deeplearning4j.org/mnist-for-beginners) on the deeplearning4j page.
The only thing that had to be adjusted is the number of output values.

The new untrained model can now be fed with the training data.
If the image is a cat, the expected output we teach the model should be 100% cat, 0% dog and vice versa.

It translates to code as follows:

```kotlin
// designing the model - mostly the same as shown at https://deeplearning4j.org/mnist-for-beginners
val conf = NeuralNetConfiguration.Builder()
                .seed(ThreadLocalRandom.current().nextLong())
                .optimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT)
                .iterations(1)
                .learningRate(0.006)
                .updater(Nesterovs(0.9))
                .regularization(true).l2(1e-4)
                .list()

                .layer(0, DenseLayer.Builder()
                        .nIn(1000) // Number of input datapoints.
                        .nOut(1000) // Number of output datapoints.
                        .activation(ActivationReLU()) // Activation function.
                        .weightInit(WeightInit.XAVIER) // Weight initialization.
                        .build()
                )
                .layer(1, OutputLayer.Builder(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD)
                        .nIn(1000)
                        .nOut(2)
                        .activation(ActivationSoftmax())
                        .weightInit(WeightInit.XAVIER)
                        .build()
                )
                .pretrain(false).backprop(true)
                .build()

        val model = MultiLayerNetwork(conf)
        model.init()

// define the answeres
val cat = Nd4j.create(doubleArrayOf(1.0,0.0))
val dog = Nd4j.create(doubleArrayOf(0.0,1.0))

// catLabels and dogLabels hold the input labels from the training set in a list
val trainingData = catLabels.map { DataSet(it, cat) } + dogLabels.map { DataSet(it, dog) }

// don't show dogs and cats one after another
Collections.shuffle(trainingData)

// feed all data to the model
model.fit(ListDataSetIterator(trainingData))
```

## Using the model

Now that the model is trained, it can give us predictions of how likely it thinks a set of input labels define a cat or a dog.
These labels for an image can be easily obtained from the VGG16 model, so all we have to do is to combine the two steps to get the likelihood of an image being a cat or a dog.

The higher value can be used for the final prediction.

```kotlin
// load vgg16 model from model zoo
val model = VGG16().initPretrained(PretrainedType.IMAGENET) as ComputationGraph

// restore the new model that was saved to a file
val catsdogsModel = ModelSerializer.restoreMultiLayerNetwork(javaClass.getResource("/catdogmodel.dl4j").openStream())

// get vgg16 labels
val image = FileInputStream("input.png")
val input = NativeImageLoader(224, 224, 3).asMatrix(image).also { VGG16ImagePreProcessor().transform(it) }
val vgg16labels = vgg16model.outputSingle(input)

// get cat/dog prediction values
val output = catsdogsModel.output(vgg16labels)
val cat = output.getDouble(0)
val dog = output.getDouble(1)

// make the prediction
if(cat > dog) println("cat") else println("dog")
```

With clear images of cats and dogs it works pretty well.

# Gamification for a Presentation in Tokyo

At [my work](https://corporate.m3.com/), we are advocating to use Kotlin in all different kind of environments, not just Android where it is mostly used today.
For that, I did [a presentation](https://speakerdeck.com/lukasjapan/kotlindeji-jie-xue-xi-vgg16moderudequan-mao-pan-duan) about using Kotlin with deeplearning4j covering the above topic.
Even the founder of Skymind, [Adam Gibson](https://en.wikipedia.org/wiki/Adam_Gibson_(computer_scientist)), decided to visit our event after I made an announcement on Twitter.
It was great to have him there.

To spice the whole thing up, I also wrote a Twitter bot that played a simple game with the audience.
The bot reacts to messages including the hashtag `#m3kt` and predicts if the profile picture of the user who sent the message shows a cat or a dog.
Whoever has the profile picture with the most likelihood of being a cat or a dog wins.

Needless to say that if you have an actual picture of a cat or dog as your profile picture, you can win the game quite easily.

It turns out that the model somehow favors cats instead of dogs for unrelated pictures.
As this was usually the case, mostly cats were entering the leaderboard with some occasional dog predictions.
Then, my bot started to react to itself and I had to hotfix it because it kept predicting its own profile picture.
I also got temporarily blocked by Twitter because of that.
Well... what can I say.
At least it helped everybody to have a great time.

In the end somebody with a cat profile picture won my little contest.
The internet is a place for cats, after all.
Nobody had a dog as the profile picture. :-(

The code for this little game and whole project in general can be found at [my Github page](https://github.com/lukasjapan/catsvsdogsgame).
It has a simple web interface and works out of the box.
It is worth to play around with.

![Results of the Cats vs Dogs game](/images/using-deeplearning4j-to-distinguish-between-cats-and-dogs/catsvsdogs.png)