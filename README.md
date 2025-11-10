# Stylus Primitives Demo

A comprehensive Rust smart contract for **Arbitrum Stylus** that demonstrates fundamental blockchain operations and primitives.

## 🎯 Overview

This contract showcases core blockchain concepts including:
- Owner management
- ETH value handling
- Address operations
- Event emission
- Cryptographic hashing
- Transaction context access

## 🏗️ Contract Architecture

### Storage
```rust
pub struct StylusPrimitivesDemo {
    owner: StorageAddress,  // Stores the contract owner's address
}
```

### Events
```rust
event EmitMe(address indexed sender, uint256 value);
```

## 📚 Functions Reference

### 1. `initialize()`
**Purpose:** Sets the caller as the contract owner  
**Access:** Public (write)  
**Use Case:** Called once after deployment to establish ownership
```rust
pub fn initialize(&mut self)
```

---

### 2. `get_msg_value()`
**Purpose:** Returns the amount of ETH sent with the transaction  
**Returns:** ETH amount in Wei (U256)  
**Access:** Public (read-only)  
**Use Case:** Check payment amounts in payable functions
```rust
pub fn get_msg_value(&self) -> U256
```

**Example:** If user sends 1 ETH, returns: 1000000000000000000 Wei

---

### 3. `get_contract_balance()`
**Purpose:** Returns the total ETH balance held by the contract  
**Returns:** Balance in Wei (U256)  
**Access:** Public (read-only)  
**Use Case:** Check contract's total holdings
```rust
pub fn get_contract_balance(&self) -> U256
```

---

### 4. `get_tx_origin()`
**Purpose:** Returns the original transaction initiator  
**Returns:** Ethereum address  
**Access:** Public (read-only)  
**Use Case:** Track the human/wallet that started the transaction chain
```rust
pub fn get_tx_origin(&self) -> Address
```

**Important:**
- `msg.sender()` = immediate caller
- `tx.origin()` = original initiator

---

### 5. `convert_gas()`
**Purpose:** Converts gas units to Stylus ink representation  
**Parameters:** `gas` - Gas value to convert  
**Returns:** Converted ink value  
**Access:** Public (read-only)
```rust
pub fn convert_gas(&self, gas: u64) -> u64
```

---

### 6. `emit_my_event()`
**Purpose:** Emits an event logging the sender and value  
**Emits:** `EmitMe(sender, value)`  
**Access:** Public  
**Use Case:** Activity logging, frontend notifications, blockchain indexing
```rust
pub fn emit_my_event(&self)
```

---

### 7. `hash_preimage()`
**Purpose:** Computes Keccak-256 hash of input data  
**Parameters:** `preimage` - Data to hash  
**Returns:** 32-byte hash  
**Access:** Public (read-only)  
**Use Case:** Commit-reveal schemes, data integrity, cryptographic proofs
```rust
pub fn hash_preimage(&self, preimage: Vec) -> [u8; 32]
```

---

### 8. `get_owner()`
**Purpose:** Returns the current owner address  
**Returns:** Owner's Ethereum address  
**Access:** Public (read-only)
```rust
pub fn get_owner(&self) -> Address
```

---

## 🚀 Quick Start

### Prerequisites

1. **Install Rust:**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. **Add WASM target:**
```bash
rustup target add wasm32-unknown-unknown
```

3. **Install Stylus CLI:**
```bash
cargo install --force cargo-stylus
```

### Setup

1. **Clone or create the project:**
```bash
mkdir stylus-primitives-demo
cd stylus-primitives-demo
```

2. **Initialize the project:**
```bash
cargo init --lib
```

3. **Copy the contract code to `src/lib.rs`**

4. **Copy the dependencies to `Cargo.toml`**

### Build
```bash
cargo build --release --target wasm32-unknown-unknown
```

### Verify
```bash
cargo stylus check
```

**Expected output:**
```
✅ Program succeeded Stylus onchain activation checks
```

### Export ABI
```bash
cargo stylus export-abi
```

---

## 🧪 Testing

Run the contract validation:
```bash
cargo stylus check
```

Run unit tests:
```bash
cargo test
```

---

## 📦 Deployment

### Deploy to Stylus Testnet

1. **Check deployment estimate:**
```bash
cargo stylus deploy \
  --private-key-path= \
  --estimate-gas
```

2. **Deploy the contract:**
```bash
cargo stylus deploy \
  --private-key-path= \
  --endpoint=https://sepolia-rollup.arbitrum.io/rpc
```

---

## 💡 Usage Examples

### Example 1: Initialize and Check Owner
```javascript
// Deploy contract
const contract = await deploy();

// Initialize (sets caller as owner)
await contract.initialize();

// Check owner
const owner = await contract.get_owner();
console.log("Owner:", owner);
```

### Example 2: Send ETH and Check Value
```javascript
// Send 1 ETH to contract
await contract.emit_my_event({ value: ethers.parseEther("1.0") });

// Check value received
const value = await contract.get_msg_value();
console.log("Value sent:", ethers.formatEther(value), "ETH");

// Check contract balance
const balance = await contract.get_contract_balance();
console.log("Contract balance:", ethers.formatEther(balance), "ETH");
```

### Example 3: Hash Data
```javascript
const data = ethers.toUtf8Bytes("secret_password");
const hash = await contract.hash_preimage(data);
console.log("Hash:", hash);
```

---

## 🔍 Key Concepts Demonstrated

| Concept | Function | Description |
|---------|----------|-------------|
| **Ownership** | `initialize()` | Setting and tracking contract owner |
| **Value Transfer** | `get_msg_value()` | Reading ETH sent with transactions |
| **Balance Checking** | `get_contract_balance()` | Querying contract's ETH holdings |
| **Transaction Context** | `get_tx_origin()` | Understanding sender vs origin |
| **Event Logging** | `emit_my_event()` | Emitting blockchain events |
| **Cryptography** | `hash_preimage()` | Using Keccak-256 hashing |
| **Type Conversion** | `convert_gas()` | Converting between gas units |

---

## 🛠️ Development Tools

- **Stylus SDK**: Rust framework for Arbitrum smart contracts
- **Cargo**: Rust package manager
- **WASM**: Compilation target for blockchain deployment
- **Alloy**: Ethereum type primitives

---

## 📖 Learning Resources

- [Stylus Documentation](https://docs.arbitrum.io/stylus/stylus-gentle-introduction)
- [Arbitrum Stylus Quickstart](https://docs.arbitrum.io/stylus/stylus-quickstart)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Ethereum Development](https://ethereum.org/en/developers/)

---

## 🐛 Troubleshooting

### Issue: `cargo stylus` not found
```bash
cargo install --force cargo-stylus
```

### Issue: WASM target missing
```bash
rustup target add wasm32-unknown-unknown
```

### Issue: Compilation errors
```bash
cargo clean
cargo update
cargo build --release --target wasm32-unknown-unknown
```

---

## 📝 License

MIT License - feel free to use this for learning and development!

---

## 🤝 Contributing

This is a learning/demo contract. Feel free to:
- Add more primitive demonstrations
- Improve documentation
- Add test cases
- Suggest improvements

---

## 📧 Contact

For questions or issues, please refer to:
- [Stylus Discord](https://discord.gg/arbitrum)
- [Arbitrum GitHub](https://github.com/OffchainLabs/stylus)

---

## ⚠️ Disclaimer

This contract is for **educational purposes only**. It has not been audited and should not be used in production without proper security review.

---

**Built with ❤️ using Arbitrum Stylus**# Primatives-Demo
