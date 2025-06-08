# ProDocto

GREEN LEAFY VEGETABLE QUALITY DIAGNOSTIC APP USING IMAGE PROCESSING
VIA TRANSFER LEARNING


## Abstract

The selection of fresh, high-quality green leafy vegetables is critical for nutrition but remains challenging for inexperienced consumers, particularly young adults with limited time and market knowledge. ProDocto addresses this issue by leveraging image processing and machine learning to diagnose produce quality, aiming to reduce food waste, improve dietary choices, and empower users assessment. The study developed a mobile application (ProDocto) using Transfer Learning with MobileNetV2 as the backbone model. A dataset of ~2,000 images of common Philippine vegetables (e.g., alugbati, pechay) was collected, preprocessed, and augmented to 7,680 samples. The model was trained via TensorFlow and deployed via a Flutter-based mobile interface with a Flask RESTful API for cloud-based inference. Performance was evaluated using accuracy, precision, recall, and F1-score, validated through confusion matrices and an independent test set. The model achieved 94% validation accuracy with strong class-specific metrics (precision/recall ≥0.91 for fresh/rotten classes). Testing on 248 real-world images revealed challenges in distinguishing "medium"-freshness produce but high reliability in detecting "rotten" samples. The app’s UI provided simple and actionable outputs, including freshness ratings, nutrient degradation data, and preparation recommendations. ProDocto demonstrates the viability of Transfer Learning for niche agricultural applications, offering a scalable tool to enhance produce selection. Future work should expand the dataset, refine "medium"-class detection, and explore edge-computing optimizations (e.g., TensorFlow Lite) for broader deployment.

Keywords: Green leafy vegetables, Quality Assessment, Image processing, Transfer Learning, MobileNetV2

