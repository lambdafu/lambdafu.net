---
title: Bayesian inference introduction
author: Marcus
layout: post
date: 2013-09-19T16:26:18+00:00
url: /2013/09/19/bayesian-inference-introduction/
categories:
  - Mathematics
tags:
  - bayes theorem
  - bayesian inference
  - machine learning
  - Python
  - statistics
  - sympy

---
I wrote a small [introduction to Bayesian inference][1], but because it is pretty heavy on math, I used the format of an [IPython notebook][2]. Bayesian inference is an important process in machine learning, with many real-world applications, but if you were born any time in the 20th century, you were most likely to learn about probability theory from a frequentist point of view. One reason may be that calculating some integrals in Bayesian statistics was too difficult to do without computers, so frequentist statistics was more economical. Today, we have much better tools, and Bayesian statistics seems more feasible. In 2010, the US Food and Drug Administration issued a [guidance document][3] explaining some of the situations where Bayesian statistics is appropriate. Overall, it seems there is a big change happening in how we evaluate statistical data, with clearer models and more precise results that make better use of the available data, even in challenging situations.

 [1]: http://nbviewer.ipython.org/urls/raw.github.com/lambdafu/notebook/master/math/Bayesian%20Coin%20Flip.ipynb
 [2]: http://ipython.org/notebook.html
 [3]: http://www.fda.gov/downloads/MedicalDevices/DeviceRegulationandGuidance/GuidanceDocuments/ucm071121.pdf