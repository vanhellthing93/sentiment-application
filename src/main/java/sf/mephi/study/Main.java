package sf.mephi.study;

import com.sun.net.httpserver.HttpServer;
import io.prometheus.client.Counter;
import io.prometheus.client.exporter.HTTPServer;
import io.prometheus.client.hotspot.DefaultExports;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class Main {
    // Метрика для подсчёта запросов
    static final Counter requestCount = Counter.build()
            .name("sentiment_requests_total")
            .help("Total number of sentiment analysis requests.")
            .register();

    public static void main(String[] args) throws IOException {
        // Регистрируем стандартные метрики JVM (куча, потоки, сборщик мусора и т.д.)
        DefaultExports.initialize();

        // Запускаем Prometheus HTTP-сервер на порту 8081
        HTTPServer prometheusServer = new HTTPServer(8081);

        // Создаём HTTP-сервер на порту 8080
        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);

        // Обработчик для эндпоинта /api/sentiment
        server.createContext("/api/v1/sentiment", exchange -> {
            requestCount.inc(); // Увеличиваем счётчик запросов
            String query = exchange.getRequestURI().getQuery();
            String text = query.split("=")[1];
            String sentiment = analyzeSentiment(text);
            String response = String.format("{\"sentiment\": \"%s\"}", sentiment);

            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(200, response.length());
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(response.getBytes());
            }
        });

        server.start();
        System.out.println("Server started on port 8080");
        System.out.println("Prometheus metrics available on port 8081");
    }

    private static String analyzeSentiment(String text) {
        if (text.contains("hello") || text.contains("happy") || text.contains("good")) {
            return "positive";
        } else if (text.contains("sad") || text.contains("bad")) {
            return "negative";
        } else {
            return "neutral";
        }
    }
}
