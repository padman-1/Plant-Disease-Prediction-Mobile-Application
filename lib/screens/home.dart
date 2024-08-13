import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_prediction/enums/plant_type.dart';
import 'package:plant_disease_prediction/service/api_service.dart';
import 'package:plant_disease_prediction/service/file_picker_service.dart';

import '../service/api_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PlantType? _plantType;
  File? _image;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  void onPlantTypeChanged(PlantType? val) {
    setState(() {
      _plantType = val;
    });
  }

  void onPickImage(ImageSource source) async {
    var res = await FilePicker.instance.pickImage(source);
    if (res != null) {
      setState(() {
        _image = File(res.path);
      });
    }
  }

  Future _onPredict() async {
    //validate if user has selected a plant type and image
    if (_image != null) {
      if (_plantType == null) {
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a plant type'),
          duration: Duration(seconds: 3),
        ));
      }
      setState(() {
        _isLoading = true;
      });
      var res = await ApiService.instance
          .getPrediction(file: _image!, plantType: _plantType!);
      setState(() {
        _isLoading = false;
      });
      if (res == null) {
        return showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  title: Text('Error'),
                  content: Text('Error getting prediction'),
                ));
      }
      String confidence = '${(res.confidence * 100).toStringAsFixed(2)}%';
      showDialog(
          context: context,
          builder: (_) => BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: AlertDialog(
                  backgroundColor: Colors.grey[300],
                  title: Center(child: const Text('Results')),
                  // contentPadding: EdgeInsets.zero,
                  // content: ConstrainedBox(
                  //   constraints: BoxConstraints(
                  //     maxHeight: 200,
                  //   ),
                  //   child: Stack(
                  //     children: [
                  //       Container(
                  //         width: double.maxFinite,
                  //         height: double.maxFinite,
                  //         decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //               image: AssetImage(
                  //                   'assets/images/plantUnsplash2.jpg'),
                  //               fit: BoxFit.cover),
                  //           borderRadius: BorderRadius.circular(15),
                  //         ),
                  //         child: ClipRRect(
                  //           borderRadius: BorderRadius.circular(15),
                  //           child: BackdropFilter(
                  //             filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  //             child: Container(
                  //               color: Colors.blueGrey.withOpacity(0.1),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Positioned(
                  //         top: 50,
                  //         left: 20,
                  //         right: 20,
                  //         child: Column(
                  //           // mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text(
                  //               'Results',
                  //               style: TextStyle(
                  //                 fontSize: 24,
                  //                 color: Colors.grey[100],
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             SizedBox(
                  //               height: 10,
                  //             ),
                  //             RichText(
                  //               text: TextSpan(
                  //                   text: 'Label: ',
                  //                   style: TextStyle(
                  //                       color: Colors.grey[100],
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.w600),
                  //                   children: [
                  //                     TextSpan(
                  //                       text: res.className,
                  //                       style: TextStyle(
                  //                           color: Colors.grey[100],
                  //                           fontSize: 18,
                  //                           fontWeight: FontWeight.w700),
                  //                     )
                  //                   ]),
                  //             ),
                  //             SizedBox(
                  //               height: 10,
                  //             ),
                  //             RichText(
                  //               text: TextSpan(
                  //                   text: 'Confidence: ',
                  //                   style: TextStyle(
                  //                       color: Colors.grey[100],
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.w600),
                  //                   children: [
                  //                     TextSpan(
                  //                         text: confidence,
                  //                         style: const TextStyle(
                  //                             color: Colors.white,
                  //                             fontSize: 18,
                  //                             fontWeight: FontWeight.w500))
                  //                   ]),
                  //             )
                  //           ],
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: 'Label: ',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            children: [
                              TextSpan(
                                  text: res.className,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600))
                            ]),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RichText(
                        text: TextSpan(
                            text: 'Confidence: ',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            children: [
                              TextSpan(
                                  text: confidence,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600))
                            ]),
                      )
                    ],
                  ),
                ),
              ));
      return;
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please select an image'),
      duration: Duration(seconds: 3),
    ));
  }

  void _onSelectImage() {
    showDialog(
        context: context,
        builder: (_) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: AlertDialog(
                // title: const Text('SELECT'),
                content: Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // TextButton(
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //       onPickImage(ImageSource.gallery);
                    //     },
                    //     child: const Text('GALLERY')),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onPickImage(ImageSource.gallery);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 60,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/gallery.png',
                              width: 70,
                              height: 40,
                            ),
                            const Text(
                              'GALLERY',
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onPickImage(ImageSource.camera);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 60,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/camera.png',
                              width: 70,
                              height: 40,
                            ),
                            const Text(
                              'CAMERA',
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // TextButton(
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //       onPickImage(ImageSource.camera);
                    //     },
                    //     child: const Text('CAMERA'))
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final devSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PLANT DISEASE DETECTION'),
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 248, 248, 240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image.asset(
                  'assets/images/PDP-logo.png',
                  height: 100,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 15),
                child: DropdownButtonFormField<PlantType>(
                  hint: const Text('Select a plant type'),
                  value: _plantType,
                  items: PlantType.values
                      .map((e) => DropdownMenuItem<PlantType>(
                            value: e,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: onPlantTypeChanged,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: _image == null
                    ? Container(
                        height: devSize.height * .27,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            color: Colors.white),
                        child: const Center(
                          child: Text('Please select an image'),
                        ),
                      )
                    : Container(
                        height: devSize.height * 0.29,
                        width: devSize.width / 1.6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        // child: Image.file(
                        //   _image!,
                        //   height: devSize.height * .3,
                        //   width: double.infinity,
                        //   // fit: BoxFit.cover,
                        // ),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 37, 145, 127),
                  // color: Color(0xFFA2B38B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton(
                    onPressed: _onSelectImage,
                    child: const Text(
                      'SELECT IMAGE',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: _onPredict,
                  child: _isLoading
                      // ? const CircularProgressIndicator()
                      ? const Text('Predicting...')
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            // color: Color(0xFFA2B38B),
                            color: Color.fromARGB(255, 37, 145, 127),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'MAKE A PREDICTION',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
