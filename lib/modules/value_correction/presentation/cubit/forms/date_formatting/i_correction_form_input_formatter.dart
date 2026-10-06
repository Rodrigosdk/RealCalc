import 'package:flutter/material.dart';

import '../../../../domain/enum/correction_index.dart';

abstract interface class ICorrectionFormInputFormatter {
  void normalizeDateFields(
    TextEditingController initialDate,
    TextEditingController finalDate,
    CorrectionIndex index,
  );

  void applyIndexDefaults(
    TextEditingController percentage,
    CorrectionIndex index,
  );
}
