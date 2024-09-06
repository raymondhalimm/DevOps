from web3 import Web3
import time

# Establish connection to a local private Geth node test network
web3 = Web3(Web3.HTTPProvider("http://localhost:51579"))

# List of pre-funded accounts on the local Ethereum network
accounts = ["0xF5504cE2BcC52614F121aff9b93b2001d92715CA",
            "0xF61E98E7D47aB884C244E39E031978E33162ff4b",
            "0xf1424826861ffbbD25405F5145B5E50d0F1bFc90",
            "0xfDCe42116f541fc8f7b0776e2B30832bD5621C85",
            "0xD9211042f35968820A3407ac3d80C725f8F75c14",
            "0xD8F3183DEF51A987222D845be228e0Bbb932C222",
            "0xafF0CA253b97e54440965855cec0A8a2E2399896"
            ]

# Check if the connections to Geth node is established
if web3.is_connected() :
    print("Connected Geth!")

    # For every pre-funded accounts, display their balance in ETH
    for account in accounts:
        balance = web3.eth.get_balance(account)
        print(f"Balance of {account}: {web3.from_wei(balance, 'ether')} ETH")

else :
    print("Connection failed!")

# Function to stress test the node by performing x count of Normal Transfer
# Parameters : from_address, private_key (of sender), to_address, amount (in ETH), and count (number of transfers)
def stress_test_normal(from_address, private_key, to_address, amount, count) :

    # Get the current nonce from sending address to ensure unique transactions
    nonce = web3.eth.get_transaction_count(from_address)

    # For loop to perform the specified number of Normal Transfer
    for x in range(count) :
        
        # Define transaction parameters
        txn = {
            "from" : from_address,
            "to" : to_address,
            "value" : web3.to_wei(amount, "ether"), # Convert ETH to Wei(Smaller Unit)
            "gas" : 21000, # Standard gas limit of a Normal Transfer
            "gasPrice" : web3.to_wei("1", "gwei"), # Gas price set to Gwei
            "nonce" : nonce+x # Ensure unique transaction
        }

        # Sign the transaction with the sender's private key
        signed_txn = web3.eth.account.sign_transaction(txn, private_key)

        # Send the signed transaction to the network
        txn_hash = web3.eth.send_raw_transaction(signed_txn.raw_transaction)

        # Print transaction hash to track the progress
        print(f"Transaction {x+1} sent: {web3.to_hex(txn_hash)}")

        # Wait for 0.3sec before next transaction
        time.sleep(0.3)

# Start the stress test by sending 200 transactions of 0.001 ETH from sender's account to receiver's account
stress_test_normal("0xfDCe42116f541fc8f7b0776e2B30832bD5621C85", "6ecadc396415970e91293726c3f5775225440ea0844ae5616135fd10d66b5954", 
                   "0xD9211042f35968820A3407ac3d80C725f8F75c14", 0.001, 200)