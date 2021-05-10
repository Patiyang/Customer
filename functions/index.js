const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fs = require("fs");
const nodemailer = require("nodemailer");

admin.initializeApp();

const gmailEmail = "patrickgithinji5@gmail.com";
const gmailPassword = "Kinyanju1!";
const mailTransport = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

const htmlmail = fs.readFileSync("welcome.html", "utf-8").toString();

exports.sendWelcomeEmail = functions.auth.user().onCreate((user) => {
  const recipentEmail = user.email;

  const mailOptions = {
    from: "'Armotale' <patrickgithinji5@gmail.com>",
    to: recipentEmail,
    subject: "Welcome to MY APP",
    html: htmlmail,
  };

  try {
    mailTransport.sendMail(mailOptions);
    console.log("mail send");
  } catch (error) {
    console.error("There was an error while sending the email:", error);
  }
  return null;
});
