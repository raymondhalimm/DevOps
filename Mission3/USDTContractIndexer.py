from web3 import Web3
from prometheus_client import start_http_server, Counter, Gauge # Prometheus client for monitoring
import time

# Alchemy URL to connect Alchemy's Ethereum node for accessing Ethereum mainnet
alchemy_url = "https://eth-mainnet.g.alchemy.com/v2/Fz-UVgCpIih6idNR2af2nNE67DS_UM8X"

# Establish connection to Web3 through Alchemy
web3 = Web3(Web3.HTTPProvider(alchemy_url))

# Print the latest block number to test connection
print(web3.eth.block_number)

# Check if connection is successful
if web3.is_connected() :
    print("Connected")
else :
    print("Failed to connect")

# USDT contract address on Ethereum mainnet
usdt_contract_address = "0xdAC17F958D2ee523a2206206994597C13D831ec7"

# Define ABI for the USDT's contract Transfer event, ABI is needed to decode events from the contract
usdt_abi = [
    {
        "anonymous": False,
        "inputs" : [
            {"indexed": True, "name": "from", "type": "address"},
            {"indexed": True, "name": "to", "type": "address"},
            {"indexed": False, "name": "value", "type": "uint256"}
        ],
        "name": "Transfer",
        "type": "event"
    }
]

# Create a contract to interact with USDT's contract address
contract = web3.eth.contract(address=usdt_contract_address, abi=usdt_abi)

# Define Prometheus metrics to track

# Counter : Increments the count of USDT transaction indexed
tx_count = Counter("usdt_tx_count", "Total Number of USDT Transactions indexed")

# Gauge : Tracks the total number of USDT tokens transferred in real time
tokens_transferred = Gauge("usdt_token_transferred", "Total USDT Tokens Transferred")

# Counter : Counts the number of large transactions (> 10,000 USDT)
large_amount_transfers = Counter("usdt_large_transfers_count", "Number of Large USDT Transactions")

# Start Prometheus metric server on port 8000 to start scraping metrics
start_http_server(8000)

# Function to handle each new Transfer event
def handle_event(event) :

    # Increment USDT transaction count
    tx_count.inc()

    # Extracts value from the event argument
    raw_value = event["args"]["value"]
    # Convert it to USDT, USDT has 6 decimals, divide by 10^6
    value = raw_value / 10**6

    # Set the current event total token transferred gauge to the variable
    tokens_transferred.set(value)

    # Print raw and converted value of the token
    print(raw_value)
    print(value)

    # Check if the token transferred is larger than 10,000 USDT
    if float(value) > 10000:

        # If true, increment large amount transaction 
        large_amount_transfers.inc()
        print("Large Transactions Alert !")

# Function to continuously loop through Transfer events and process
def log_loop(event_filter, poll_interval) :

    # Continuous loop to keep fetching new events
    while True:
        # Get all new events from the filter and process
        for event in event_filter.get_new_entries():
            handle_event(event)
        # Sleep for specified time interval before running again
        time.sleep(poll_interval)

# Create a filter for the Transfer event starting from the latest block and listens for new events emitted by the USDT contract
transfer_filter = contract.events.Transfer.create_filter(from_block="latest")

# Start the function to continuously poll for new Transfer events
log_loop(transfer_filter, 2)