/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// Include event listner at frontend

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// Compile locally - $npx hardhat compile and verify src/artifcats/contracts, edit scripts/deploy.js also with contract name
// Test - $npx hardhat test

// $npx hardhat node to develope locally
// $npx hardhat run scripts/deploy.js --network localhost, this will help you get the deployed contract acccount

// Write UI for this - Edit src/App.js 
// $yarn start with metamask

// Organize the project with frontend
contract Escrow {
    uint public price;
    address payable public seller;
    address payable public buyer;

    // Include openzepplin library for this to increase?
    // total_successful_purchases
    // uint public total_sales = 0; 

    address[] previousBuyers;

    // Include item here later to describe the product?
    // Optionally include function to update it?
    // struct Item {
    //     string name;
    //     string image;
    //     string description;
    //     string external_link;
    // }

    // Item public item;

    // Title,
    // Description
    // Image

    // uint(vt);
    enum State { Sale, Locked, Release, Closed, Complete } // 0, 1, 2, 3, 4?
    // enum State { Sale, Locked, Release, Closed, Complete, End } // 0, 1, 2, 3, 4, 5?
    
    // enum State { Created, Locked, Release, Closed, Complete, End } // 0, 1, 2, 3?
    // The state variable has a default value of the first member, `State.created`
    State public state;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyBuyer() {
        require(
            msg.sender == buyer,
            "Only buyer can call this."
        );
        _;
    }

    modifier onlySeller() {
        require(
            msg.sender == seller,
            "Only seller can call this."
        );
        _;
    }

    modifier notSeller() {
        require(
            msg.sender != seller,
            "Seller shouldn't call this."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }

    event Closed(
        uint256 when
    );

    event ConfirmPurchase(
        uint256 when,
        address by
    );
    event ConfirmReceived(
        uint256 when,
        address by
    );
    
    event SellerRefundBuyer(
        uint256 when
    );
    event SellerRefunded(
        uint256 when
    );

    event Restarted(
        uint256 when
    );
    event End(
        uint256 when
    );

    /// Ensure that `msg.value` is an even number.
    /// Division will truncate if it is an odd number.
    /// Check via multiplication that it wasn't an odd number.
    /// 1.
    constructor() payable {
        // How to start with more value for the contract?
        // after you deploy contract, the account balance becomes from 10000 to 9999.9968
        seller = payable(msg.sender);

        price = msg.value / 2; // Is this automatically caluclated?
        
        require((2 * price) == msg.value, "Value has to be even.");
    }

    // I want to test the current status of contract, so inlcude this
    // Is there a better way for this? or to read something, you should use this?
    // function currentState()
    //     public
    //     view
    //     returns (State)
    // {
    //     return state;
    // }

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    /// 2.
    function close()
        public
        onlySeller
        inState(State.Sale)
    {
        state = State.Closed;
        // We use transfer here directly. It is
        // reentrancy-safe, because it is the
        // last call in this function and we
        // already changed the state.
        seller.transfer(address(this).balance); // Should manually check the change at metamask?
        
        emit Closed(
            block.timestamp
        ); // How to listen to this?
    }

    // /// Confirm the purchase as buyer.
    // /// Transaction has to include `2 * value` ether.
    // /// The ether will be locked until confirmReceived
    // /// is called.
    function confirmPurchase()
        public
        notSeller
        inState(State.Sale)
        condition(msg.value == (2 * price))
        payable
    {
        buyer = payable(msg.sender);
        state = State.Locked;

        emit ConfirmPurchase(
            block.timestamp,
            buyer
        );
    }

    // /// Confirm that you (the buyer) received the item.
    // /// This will release the locked ether.
    function confirmReceived()
        public
        onlyBuyer
        inState(State.Locked)
    {
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Release;

        buyer.transfer(price); // Buyer receive 1 x value here
        emit ConfirmReceived(
            block.timestamp,
            buyer
        );
    }

    function refundBuyer()
        public
        onlySeller
        inState(State.Locked)
    {
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Sale;
        buyer.transfer(2 * price); // Buyer receive 2 x value paid before if the seller don't want to sell it.
        buyer = payable(0);
        
        emit SellerRefundBuyer(
            block.timestamp
        );
    }

    /// This function refunds the seller, i.e.
    /// pays back the locked funds of the seller.
    function refundSeller()
        public
        onlySeller
        inState(State.Release)
    {
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Complete;
        
        seller.transfer(3 * price); // Seller receive 3 x value here

        // total_sales = total_sales + 1; // Include openzepplin library for this to increase?
        previousBuyers.push(buyer);

        emit SellerRefunded(
            block.timestamp
        );
    }

    // Should test it work
    function restartContract() 
        public
        onlySeller
        // inState(State.Complete)
        payable
    {
        if (state == State.Closed || state == State.Complete) {
            require((2 * price) == msg.value, "Value has to be equal to what started the contract.");

            state = State.Sale;
            
            // Reset buyer to allow the same buyer again?
            buyer = payable(0);
            // This doesn't work.
            // buyer = address(0);

            emit Restarted(
                block.timestamp
            );
        }
    }

    // function showState() public view returns (uint) {
    //     // With uint, it returns Enum value instead of index
    //     return uint(state);
    // }

    function listPreviousBuyers()public view returns(address [] memory){
        return previousBuyers;
    }

    // totalPreviousBuyers
    function totalSales() public view returns(uint count) {
        return previousBuyers.length;
    }

    function end() 
        public
        onlySeller
    {
         if (state == State.Closed || state == State.Complete) {
            emit End(
                block.timestamp
            );
            
            // state = State.End;
            selfdestruct(seller);
            // After a contract calls selfdestruct, the code and storage associated with the contract are removed from the Ethereum's World State.
            // Transactions after that point will behave as if the address were an externally owned account, i.e. transaction will be accepted, no processing will be done, and the transaction status will be success.
            // Transactions will do nothing, but you still have to pay the transaction fee. You can even transfer ether. It will be locked forever or until someone finds one of the private keys associated with that address.
            // emit End(); // Will this work?

            // This doesn't work
            // emit End(
            //     block.timestamp
            // );
            
        }
    }
}