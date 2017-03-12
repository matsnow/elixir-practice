defmodule Demo.WebSocketHandler do
    @behaviour :cowboy_websocket

    # 必須
    def init(req, opts) do
       {:cowboy_websocket, req, opts} 
    end

    # インターフェース上は実装任意
    def websocket_init(opts) do
       Phoenix.PubSub.subscribe(:chat_pubsub, "my_topic")
       {:ok, opts}
    end

    # 必須
    # テキストデータを受け取った場合
    def websocket_handle({:text, content}, opts) do
       Phoenix.PubSub.broadcast(:chat_pubsub, "my_topic", {:text, content})
       {:ok, opts}
    end
    # テキストデータ以外を受け取った場合
    def websocket_handle(_in_frame, opts) do
       {:ok, opts}
    end

    # 必須
    def websocket_info({:text, content}, opts) do
       {:reply, {:text, content}, opts}
    end
    def websocket_info(_info, opts) do
       {:ok, opts}
    end

    # 任意
    def terminate(_reason, _req, _opts) do
       Phoenix.PubSub.unsubscribe(:chat_pubsub, "my_topic")
       :ok
    end
end