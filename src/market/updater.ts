import axios from "axios";
import { Sender } from "@questdb/nodejs-client";

type BinanceAvgResponse = {
    data: {
        mins: number;
        price: string;
    };
};
type GeminiPriceFeedResponse = {
    data: Array<{
        pair: string;
        price: string;
        percentChange24h: string;
    }>;
};
async function main() {
    // create a sender with a 4k buffer
    const sender = new Sender({ bufferSize: 4096 });

    // connect to QuestDB
    // host and port are required in connect options
    await sender.connect({ port: 9009, host: "localhost" });

    async function getBinanceData() {
        const { data }: BinanceAvgResponse = await axios.get(
            "https://api.binance.us/api/v3/avgPrice?symbol=BTCUSD"
        );

        // add rows to the buffer of the sender
        sender
            .table("prices")
            .symbol("pair", "BTCUSD")
            .stringColumn("exchange", "Binance")
            .floatColumn("bid", parseFloat(data.price))
            .atNow();

        await sender.flush();

        setTimeout(getBinanceData, 1000);
    }

    async function getGeminiData() {
        const { data }: GeminiPriceFeedResponse = await axios.get(
            "https://api.gemini.com/v1/pricefeed"
        );
        const { price } = data.find((i) => i.pair === "BTCUSD") || {
            price: "-1",
        };

        if (price !== "-1") {
            // add rows to the buffer of the sender
            sender
                .table("prices")
                .symbol("pair", "BTCUSD")
                .stringColumn("exchange", "Gemini")
                .floatColumn("bid", parseFloat(price))
                .atNow();

            await sender.flush();
        }

        setTimeout(getGeminiData, 1000);
    }

    getBinanceData();
    getGeminiData();
}

main();
