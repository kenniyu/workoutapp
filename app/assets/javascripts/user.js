function ProfileEditor(options) {
  var self          = this;

  self.containers     = options['containers'];
  self.$bmrContainer  = $(self.containers['bmr']);
  self.$hbfContainer  = $(self.containers['hbf']);
  self.$lbmContainer  = $(self.containers['lbm']);
  self.$form          = $(self.containers['form']);

  self.$ageInput            = $(self.containers['age-input']);
  self.$genderMaleInput     = $(self.containers['gender-male-input']);
  self.$genderFemaleInput   = $(self.containers['gender-female-input']);
  self.$weightInput         = $(self.containers['weight-input']);
  self.$heightInput         = $(self.containers['height-input']);
  self.$bodyFatPctInput     = $(self.containers['body-fat-pct-input']);
  self.$activityLevelInput  = $(self.containers['activity-level-input']);
  self.bmrMultipliers       = {
                                1: 1.2,
                                2: 1.375,
                                3: 1.55,
                                4: 1.725,
                                5: 1.9
                              };

  this.initControls = function() {
    self.initFormChange();
  }

  this.initFormChange = function() {
    self.$form.on('change', 'input', function(event) {
      self.updateFormulas();
    });
    self.$form.on('change', 'select', function(event) {
      self.updateFormulas();
    });
  }

  this.updateFormulas = function() {
    var age           = parseFloat(self.$ageInput.val()),
        gender        = self.$genderMaleInput.attr('checked') === 'checked' ? 'Male' : 'Female',
        weight        = parseFloat(self.$weightInput.val()),
        height        = parseFloat(self.$heightInput.val()),
        bodyFatPct    = parseFloat(self.$bodyFatPctInput.val()),
        activityLevel = parseInt(self.$activityLevelInput.val()),
        bmr,
        hbf,
        lbm;

    if ( isNaN(age) || isNaN(weight) || isNaN(height) || isNaN(bodyFatPct) || isNaN(activityLevel) ) {
      // do nothing if one field is fucked up
    } else {
      if (gender == 'Female') {
        bmr = (655 + (4.35 * weight) + (4.7 * height) - (4.7 * age)).toFixed(2);
      } else {
        bmr = (66 + (6.23 * weight) + (12.7 * height) - (6.8 * age)).toFixed(2);
      }
      lbm = ((100 - bodyFatPct)/100 * weight).toFixed(2);
      hbf = (bmr * self.bmrMultipliers[activityLevel]).toFixed(2);
      self.$bmrContainer.text(bmr);
      self.$hbfContainer.text(hbf);
      self.$lbmContainer.text(lbm);
    }
  }


}
