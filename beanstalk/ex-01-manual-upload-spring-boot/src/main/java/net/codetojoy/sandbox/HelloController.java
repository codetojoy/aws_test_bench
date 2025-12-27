package net.codetojoy.sandbox;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.view.RedirectView;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
public class HelloController {

    @GetMapping("/")
    public RedirectView home() {
        return new RedirectView("/hello");
    }

    @GetMapping("/hello")
    public String hello() {
        LocalDateTime currentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMMM dd, yyyy hh:mm:ss a");
        String formattedDateTime = currentDateTime.format(formatter);

        String foobarValue = System.getenv("FOOBAR");
        if (foobarValue == null || foobarValue.isEmpty()) {
            foobarValue = "N/A";
        }

        return "<html><body>" +
               "<h1>Hello World!</h1>" +
               "<p>Current Date and Time: " + formattedDateTime + "</p>" +
               "<p>FOOBAR: " + foobarValue + "</p>" +
               "</body></html>";
    }
}
