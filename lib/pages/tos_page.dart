import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Health Companion Terms of Service\n',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Welcome to Health Companion! We’re so glad you’ve decided to use our mobile application. Before you dive in, let’s walk through our Terms of Service, the legally binding contract you absolutely, definitely, have time to read through (don’t worry, we sprinkled in some truth here and there, in the spirit of transparency, of course).\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '1. Acceptance of Terms\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'By downloading, installing, or using Health Companion, you’re not just agreeing to these Terms of Service but also declaring that you’ve read every word (wink wink) and accept the infinite power we have over your usage of this app. Seriously, though, using the app means you are bound by these terms.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '2. Changes to Terms\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We reserve the right to update or change these terms at any time. We\'ll notify you by changing the date at the top of these Terms. That is it. If you keep using the app after changes, you’re totally fine with whatever we’ve decided to include, be it reasonable adjustments or whimsical new rules.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '3. Account Responsibility\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You’re responsible for keeping your login details super-duper secret. If anyone else uses your account, you’re also responsible for whatever they do on the app, whether it’s logging meals, tracking steps, or ordering a pizza using your stored card details.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '4. Data Collection\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Health Companion will collect data on your health, activities, preferences, favorite pizza toppings, and basically anything else we can think of that might be remotely useful. Rest assured, your data helps us, help you—among other interested parties.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '5. Use of Data\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We promise to use your data to improve your experience with the app, tailor recommendations, and also, share it with our partners and advertisers (because who doesn’t need another gym membership pitch, right?). Your data might even be sent to the far corners of the universe, but only for entirely ethical, noble reasons.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '6. User Conduct\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We expect you to behave impeccably while using Health Companion. No cheating on your step count, logging fictional workouts, or misrepresenting your kale smoothie as a burger. This is serious business, after all.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '7. Intellectual Property\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Everything within Health Companion—logos, content, snazzy icons—is our property. Feel free to enjoy it within the app, but remember, “borrowing” or “repurposing” any part of it without our explicit, written consent is a no-go.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '8. Termination\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We reserve the right to terminate your access to Health Companion for any reason, at any time, without prior notice. Maybe you didn’t log enough squats or took too many cheat days. Who knows? Stay in our good graces, and we’ll be good to you.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '9. Limitation of Liability\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Health Companion is here to assist, not to be a certified health advisor, life coach, or a miracle worker. We’re not liable for any unfortunate events or mishaps, including but not limited to, exercise injuries, weight loss plateau frustrations, or the unexpected discovery of a chocolate stash.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '10. Governing Law\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'These terms and your use of Health Companion will be governed by the laws of wherever we decide because, let’s be real, who’s actually reading this part? In case of disputes, you agree to arbitration in our hometown, which might as well be on Mars.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '11. Contact Information\n',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Questions, comments, or concerns about these Terms of Service? Feel free to reach out to us at [email protected], and we promise to get back to you...eventually.\n',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Accept and Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
