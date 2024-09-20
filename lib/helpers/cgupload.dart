import 'dart:io';

import 'package:cardemo/cameraimageupload.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cardemo/helpers/color.dart';

class Cgupload extends StatefulWidget {
  final String certname;
  final Function updateData;
  final Function showOptions;
  final String imgPath;
  const Cgupload(this.certname, this.imgPath, this.updateData, this.showOptions,
      {Key? key})
      : super(key: key);

  @override
  State<Cgupload> createState() => _CguploadState();
}

class _CguploadState extends State<Cgupload> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.certname,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ElevatedButton(
                child: const Text(
                  "Upload",
                  style: TextStyle(color: Color(0xFF0D47A1)),
                ),
                onPressed: () async {
                  widget.showOptions(widget.updateData);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(yellow),
                ),
              )
            ],
          ),
          widget.imgPath != "" ? Image.file(File(widget.imgPath)) : Container()
        ],
      ),
    );
  }
}
