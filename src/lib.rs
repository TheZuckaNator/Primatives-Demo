#![cfg_attr(not(feature = "export-abi"), no_main)]
extern crate alloc;

use stylus_sdk::{
    prelude::*,
    alloy_primitives::{Address, U256},
    storage::StorageAddress,
    crypto,
};
use alloy_sol_types::{sol, SolEvent};

// Define your event using alloy_sol_types
sol! {
    event EmitMe(address indexed sender, uint256 value);
}

#[storage]
#[entrypoint]
pub struct StylusPrimitivesDemo {
    owner: StorageAddress,
}

#[public]
impl StylusPrimitivesDemo {
    // 1. Set the caller as the contract's owner
    pub fn initialize(&mut self) {
        let sender = self.vm().msg_sender();
        self.owner.set(sender);
    }
    
    // 2. Return the amount of ETH sent with the current call
    pub fn get_msg_value(&self) -> U256 {
        self.vm().msg_value()
    }
    
    // 3 & 4. Store contract address and return its balance
    pub fn get_contract_balance(&self) -> U256 {
        let this_contract = self.vm().contract_address();
        self.vm().balance(this_contract)
    }
    
    // 5. Return the original sender of the transaction
    pub fn get_tx_origin(&self) -> Address {
        self.vm().tx_origin()
    }
    
    // 6. Convert gas value into ink representation
    pub fn convert_gas(&self, gas: u64) -> u64 {
        self.vm().gas_to_ink(gas)
    }
        
    // 7. Emit the EmitMe event
    pub fn emit_my_event(&self) {
        let sender = self.vm().msg_sender();
        let value = self.vm().msg_value();
        
        let event = EmitMe {
            sender,
            value,
        };
        
        // Encode the event properly
        let mut topics = vec![];
        event.encode_topics_raw(&mut topics).expect("failed to encode topics");
        
        let data = event.encode_data();
        
        // Emit with correct format
        self.vm().emit_log(&data, topics.len());
    }
    
    // 8. Return keccak256 hash of preimage
    pub fn hash_preimage(&self, preimage: Vec<u8>) -> [u8; 32] {
        crypto::keccak(&preimage).into()
    }
    
    // Helper: Get owner
    pub fn get_owner(&self) -> Address {
        self.owner.get()
    }
}