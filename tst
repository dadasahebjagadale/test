Great question.

Short Answer:

No, Symphony does not support real-time "push-based" listeners (like WebSocket callbacks) for bots. The standard way is to poll the message endpoint at regular intervals — this is the only approach when SDKs or WebHooks are not permitted, as in your case.


---

Why Polling is Required?

Symphony's backend does not push new messages to you. Bots poll the Datafeed or chatroom API repeatedly to "listen" for new messages.

So your "listener" is a Vert.x timer that:

Polls every few seconds.

Checks for new messages.

Triggers your logic if a new message arrives.



---

How to Build a Real-Time-like Listener Using Vert.x

You simulate a listener using Vert.x setPeriodic, like this:

1. Listener Class

public class SymphonyMessageListener {

    private final WebClient client;
    private final Vertx vertx;
    private final String authKey;
    private final String baseUrl;
    private final String roomName;

    private String lastMessageId = null;

    public SymphonyMessageListener(Vertx vertx, String baseUrl, String authKey, String roomName) {
        this.vertx = vertx;
        this.client = WebClient.create(vertx);
        this.authKey = authKey;
        this.baseUrl = baseUrl;
        this.roomName = roomName;
    }

    public void startListening(Handler<JsonObject> messageHandler) {
        vertx.setPeriodic(2000, id -> {
            client.getAbs(baseUrl + "/chatroom/" + roomName + "/messages") // Adjust path as needed
                .putHeader("Authorization", authKey)
                .send(ar -> {
                    if (ar.succeeded()) {
                        JsonArray messages = ar.result().bodyAsJsonArray();
                        for (int i = 0; i < messages.size(); i++) {
                            JsonObject msg = messages.getJsonObject(i);
                            String msgId = msg.getString("id");

                            if (lastMessageId == null || msgId.compareTo(lastMessageId) > 0) {
                                lastMessageId = msgId;
                                messageHandler.handle(msg);  // Trigger your callback
                            }
                        }
                    } else {
                        System.err.println("Failed to fetch messages: " + ar.cause().getMessage());
                    }
                });
        });
    }
}


---

2. How to Use the Listener in Your Verticle

public class MainVerticle extends AbstractVerticle {

    @Override
    public void start() {
        String baseUrl = "https://your-symphony-url.com";
        String authKey = "your-auth-key";
        String roomName = "your-room-name";

        SymphonyMessageListener listener = new SymphonyMessageListener(vertx, baseUrl, authKey, roomName);
        listener.startListening(message -> {
            // Your business logic here
            System.out.println("New message received: " + message.encodePrettily());
        });
    }
}


---

What You Achieve with This?

You simulate a real-time listener using scheduled polling.

You can reuse startListening() anywhere and handle messages via callback.

The Handler<JsonObject> lets you plug in any custom logic.



---

Let me know:

The exact path of your GET message API (e.g., /messages?room=xyz) — I’ll tailor the code precisely.

Whether the message payload contains a timestamp or ID — we can then improve deduplication.
