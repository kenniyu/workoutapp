function Goal(options) {
  var self          = this;

  self.containers     = options['containers'];
  self.submitUrl      = options['submitUrl'];
  self.$form          = $(self.containers['form']);
  self.GOAL_TYPES     = {
                          'Lose Fat': 'LF',
                          'Gain Muscle': 'GM'
                        };

  self.$dueDateInput        = $(self.containers['due-date-input']);
  self.$goalNameInput       = $(self.containers['goal-name-input']);
  self.$goalTypeInput       = $(self.containers['goal-type-input']);
  self.$startValueInput     = $(self.containers['start-value-input']);
  self.$finalValueInput     = $(self.containers['final-value-input']);
  self.$deltaValueContainer = $(self.containers['delta-input']);
  self.$deltaTimeContainer  = $(self.containers['delta-time']);
  self.$goalDescInput       = $(self.containers['goal-description-input']);
  self.$spinnerContainer    = $(self.containers['spinner-container']);
  self.$submitBtn           = $(self.containers['goal-submit']);
  self.$goalRate            = $(self.containers['goal-rate']);
  self.formSubmitted        = false,
  self.goalRates            = {
                                'LF': { 'threshold': 500 },
                                'GM': { 'threshold': 500 }
                              };

  self.CALORIES_PER_POUND   = 3500;

  this.initControls = function() {
    self.initFormChange();
  }

  this.initFormChange = function() {
    self.$form.on('change', function(event) {
      self.updateFields(event);
    });
  }

  this.updateFields = function(event) {
    var $changedInput = $(event.target),
        inputId       = $changedInput.attr('id'),
        validInputs   = self.validateGoal(),
        startVal,
        finalVal,
        delta,
        currentDate   = new Date(),
        goalDate,
        period;

    if (validInputs) {
      self.$submitBtn.removeAttr('disabled');
      // determine delta
      startVal  = parseFloat(self.$startValueInput.val()),
      finalVal  = parseFloat(self.$finalValueInput.val()),
      delta     = finalVal - startVal;
      goalDate  = self.$dueDateInput.val();
      period    = Math.floor(( Date.parse(goalDate) - Date.parse(currentDate) ) / 86400000);


      self.$deltaValueContainer.text(delta);
      self.$deltaTimeContainer.text(period);
      self.$deltaValueContainer.closest('.fieldset').removeClass('inactive');

      self.showGoalRate();
    } else {
      self.$submitBtn.attr('disabled', 'disabled');
      self.$deltaValueContainer.closest('.fieldset').addClass('inactive');
    }
  }

  this.validateGoal = function() {
    var goalTypeVal = self.$goalTypeInput.val(),
        startVal    = parseFloat(self.$startValueInput.val()),
        finalVal    = parseFloat(self.$finalValueInput.val()),
        currentDate = Date.parse(new Date()),
        dueDateVal  = Date.parse(self.$dueDateInput.val()),
        errors      = [],
        errorHash;

    $('.error').addClass('inactive');

    if (goalTypeVal === self.GOAL_TYPES['Lose Fat']) {
      if (finalVal > startVal) {
        errorHash = {
          'msg': 'To lose fat, you must enter a value less than your current weight',
          'container': $('#' + self.$finalValueInput.attr('id')).next('.error')
        }
        errors.push(errorHash);
      }
    } else if (goalTypeVal === self.GOAL_TYPES['Gain Muscle']) {
      if (startVal > finalVal) {
        errorHash = {
          'msg': 'To gain muscle, you must enter a value greater than your current weight',
          'container': $('#' + self.$finalValueInput.attr('id')).next('.error')
        }
        errors.push(errorHash);
      }
    }

    if (self.formSubmitted) {
      if (self.$goalNameInput.val() === '') {
        errorHash = {
          'msg': 'Please enter a goal name',
          'container': $('#' + self.$goalNameInput.attr('id')).next('.error')
        }
        errors.push(errorHash);
      }
      if (self.$goalTypeInput.val() === '') {
        errorHash = {
          'msg': 'Please choose a valid goal type',
          'container': $('#' + self.$goalTypeInput.attr('id')).next('.error')
        }
        errors.push(errorHash);
      }
      if (self.$dueDateInput.val() === '') {
        errorHash = {
          'msg': 'Please select a valid date',
          'container': $('#' + self.$dueDateInput.attr('id')).next('.error')
        }
        errors.push(errorHash);
      }
      if (self.$finalValueInput.val() === '') {
        errorHash = {
          'msg': 'Please enter a goal weight',
          'container': $('#' + self.$finalValueInput.attr('id')).next('.error')
        }
        errors.push(errorHash);
      }
    }

    if (dueDateVal <= currentDate) {
      errorHash = {
        'msg': 'Please set a date in the future.',
        'container': $('#' + self.$dueDateInput.attr('id')).next('.error')
      }
      errors.push(errorHash);
    }


    for (var i = 0; i < errors.length; i++) {
      errorHash = errors[i];
      errorHash['container'].text(errorHash['msg']);
      errorHash['container'].removeClass('inactive');
    }

    if (errors.length > 0 || isNaN(startVal) || isNaN(finalVal) || isNaN(dueDateVal) || goalTypeVal === '') {
      return false;
    } else {
      return true;
    }
  }

  this.handleFormSuccess = function(redirectUrl) {
    self.$form.slideUp(200, function() {
      self.$form.remove();
      $('.goals-wrapper').html('<p>Goal created!</p>');
      setTimeout(function() {
        document.location.href = redirectUrl;
      }, 3000);
    });
  }

  this.showGoalRate = function() {
    var startVal,
        finalVal,
        delta,
        currentDate   = new Date(),
        goalDate,
        period,
        totalCaloricDelta,
        dailyCaloricDelta,
        goalType = self.$goalTypeInput.val(),
        goalRateThreshold,
        goalRateText;

    // determine delta
    startVal  = parseFloat(self.$startValueInput.val()),
    finalVal  = parseFloat(self.$finalValueInput.val()),
    delta     = finalVal - startVal;
    goalDate  = self.$dueDateInput.val();
    period    = Math.floor(( Date.parse(goalDate) - Date.parse(currentDate) ) / 86400000);

    totalCaloricDelta = delta * self.CALORIES_PER_POUND;
    dailyCaloricDelta = totalCaloricDelta/period;

    goalRateThreshold = self.goalRates[goalType]['threshold'];
    if (Math.abs(dailyCaloricDelta) <= goalRateThreshold) {
      goalRateText = '(steady)';
    } else {
      goalRateText = '(drastic)';
    }

    self.$goalRate.text(goalRateText);
  }
}

function GoalPreview(options) {
  var self          = this;

  self.containers           = options['containers'];
  self.$goalsListContainer  = $(self.containers['goalsListContainer']);
  self.$previewContainer    = $(self.containers['previewContainer']);
  self.previewGoalBaseUrl   = options['previewGoalBaseUrl'];

  this.initControls = function() {
    self.initGoalPreviewLinks();
    self.initGoalPreviewHeight();
  }

  this.initGoalPreviewLinks = function() {
    self.$goalsListContainer.on('click', '.goal-preview', function(event) {
      self.showGoalPreview(event);
    });
  }

  this.initGoalPreviewHeight = function() {
    var adjustedHeight = self.$goalsListContainer.outerHeight() + 2;
    self.$previewContainer.css('min-height', adjustedHeight);
  }

  this.showGoalPreview = function(event) {
    var $goal   = $(event.target),
        goalId  = $goal.attr('data-goal-id');
    $goal.closest('.goals-list').find('.goal-item').removeClass('selected');
    $goal.closest('.goal-item').addClass('selected');

    $.ajax({
      type: 'GET',
      beforeSend: function(xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
      },
      url: self.previewGoalBaseUrl + '/' + goalId
    });
    event.preventDefault();
  }

}
