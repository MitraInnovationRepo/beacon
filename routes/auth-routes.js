const router = require('express').Router();
const passport = require('passport');
const Customer=require('../models/customer-model');
router.get("/login", (req, res) => {
  res.render('login');
})


router.get("/", (req, res) => {
  if (req.user) {
    // db update function
    // redirect to auth URL
    Customer.findByIdAndUpdate(
      { _id: req.user.id }, 
      { $push: { shopIDs:req.query.gatewayname} },
     function (error, success) {
           if (error) {
               console.log(error);
           } else {
               console.log(success);
           }
       });


//  
    res.send("Yolla bitchers")
  } else {
    res.redirect('/auth/login');
  }
})

// passport authentication
router.get("/google", passport.authenticate('google', {
  scope: ['profile']
}))

router.get("/google/redir", passport.authenticate('google', { failureRedirect: '/login' }),
  function (req, res) {
    // Successful authentication, redirect home.
    res.send(req.user);
  })

module.exports = router;