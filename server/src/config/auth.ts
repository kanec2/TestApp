import { JWT, auth } from "@colyseus/auth";
import { findUser, findUserByEmail } from "../repository/UserRepository";


/**
 * Email / Password Authentication
 */
auth.settings.onFindUserByEmail = async (email) => {
  console.log("@colyseus/auth: onFindByEmail =>", { email });
  return await findUserByEmail(email);
};

auth.settings.onRegisterWithEmailAndPassword = async (email, password, options) => {
  console.log("@colyseus/auth: onRegister =>", { email, password, ...options });

  // Validate custom "options"
  const additionalData: any = {};
  if (options.birthdate) { additionalData.birthdate = options.birthdate; }
  if (options.custom_data) { additionalData.custom_data = JSON.stringify(options.custom_data); }
  if (options.locale) { additionalData.locale = options.locale; }
  const name = options.name || email.split("@")[0];
  return await  createUser({
    name,
    email,
    password,
    ...additionalData,
  });
}

auth.settings.onSendEmailConfirmation = async (email, html, link) => {
  await resend.emails.send({
    from: 'web-template@colyseus.io',
    to: email,
    subject: '[Colyseus Web Template]: Reset password',
    html,
  });
}

auth.settings.onForgotPassword = async (email: string, html: string/* , resetLink: string */) => {
  await resend.emails.send({
    from: 'web-template@colyseus.io',
    to: email,
    subject: '[Colyseus Web Template]: Reset password',
    html,
  });
}

auth.settings.onResetPassword = async (email: string, password: string) => {
  await User.update({ password }).where("email", "=", email).execute();
}

/**
 * OAuth providers
 */
auth.oauth.addProvider('discord', {
  key: process.env.DISCORD_CLIENT_ID,
  secret: process.env.DISCORD_CLIENT_SECRET,
  scope: ['identify', 'email'],
});

// auth.oauth.defaults.origin = "http://localhost:2567";

auth.oauth.addProvider('twitch', {
  key: "3a3311zpk0vimb7mjxtw7n1axbidtx",
  secret: "s78w1l2tyeyvxz25ypovn26q90ky53",
  scope: ['user:read:email'],
});

auth.oauth.onCallback(async (data, provider) => {
  const profile = data.profile;
  console.log("DATA:", data);
  console.log("PROFILE:", profile);

  return await createUser(profile);
});

export function createUser(profile: any) {
  return User.upsert({
    discord_id: profile.id,
    name: profile.global_name || profile.username || profile.login,
    locale: profile.locale || "",
    email: profile.email,
  })
}