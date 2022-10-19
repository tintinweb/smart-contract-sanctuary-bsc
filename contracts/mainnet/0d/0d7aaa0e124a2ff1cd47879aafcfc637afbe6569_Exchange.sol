/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT
// Vulcano Exchange 1.4

pragma solidity ^0.8.0;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////   INTERFACES  ///////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

// IRC20 interface needed to use the token methods
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

//////////////////////////////////////////////////////////// Contract ////////////////////////////////
contract Exchange {
    ///////////////////////////// EVENTS ///////////////////////////

    //Notifying successful exchange Virtual Token => Token
    event e_newExchangeForToken(
        address indexed owner,
        uint256 virtualDebited,
        uint256 tokenDelivered
    );
    //Notifying successful exchange Token => Token
    event e_newExchangeforVirtualToken(
        address indexed owner,
        uint256 tokenDebited,
        uint256 virtualDelivered
    );

    //////////////////////////  STATES /////////////////////////////

    //Fee Value
    uint256 private value;
    // Token Address
    address private ERC20_ADDRESS;
    // Admin Wallet
    address private admin;
    //Exchange Status
    bool private open;
    //Authorizer walllet
    address authorizer;

    ///////////////////////// MAPPINGS //////////////////////////////

    //Mapping that saves in boolean if the wallet has made the corresponding payment in virtual tokens to authorize it to receive Token
    mapping(address => bool) private m_walletPreauth;

    //Authorized amount for the user corresponding to what he paid for the exchange
    mapping(address => uint256) private m_amountAuthorized;

    ////////////////////////////////////////  CONSTRUCTOR /////////////////////////////////////////////////////////

    //This initialize will be used only if this contract is deployed as a proxy, for which it needs the state initializer function, if it is not a proxy, the initialize function will not be necessary
    constructor() {
        // Fee value
        value = 2000000000000000;
        // Token address
        ERC20_ADDRESS = 0x3810a078AA274Ea6d06a480588eFf8fE517220a4; // Dummy Token Created at Tesnet. For production, the real contract address must be placed
        // admin address
        admin = 0x823ec51FA4d45476fAC265196FEa3964da3a91f4; //change in prod by the selected administrator wallet
        //exchange open
        open = true; //place in prod the state in which the exchange will be at the time of displaying this contract
        //Authorizer address
        authorizer = 0xd5FAA1fA6DE6C5ffa18c7e7C007F79D4FEFb4441; // change in prod by the selected authorizing wallet
    }

    /////////////////////////////////////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////// MODIFIERS ///////////

    /* Security modifier that does not allow a user to charge an exchange until a previous one has been completed, 
    this is done to  prevent reetrancy calls
    The flag variable is initialized to false, the state is asserted to continue, then set to true, 
    the entire underlying function is executed, then set back to false
    */
    modifier security() {
        bool flag;
        require(!flag, "wait to previous transaction");
        flag = true;
        _;
        flag = false;
    }
    //the function that has this modifier can only be called by the admin
    modifier adminExchange() {
        require(
            msg.sender == admin,
            "only administrator can call this function"
        );
        _;
    }
    //the function that has this modifier can only be called by the authorizer
    modifier authorizerExchange() {
        require(
            msg.sender == authorizer,
            "only authorizer can call this function"
        );
        _;
    }

    ////////////// PUBLIC AND EXTERNAL FUNCTIONS ////////

    //Function to change the amount of the exchange fee, can only be called by the admin, the value must be sent in WEIS
    function setExchangeValue(uint256 newValue)
        external
        adminExchange
        returns (uint256)
    {
        value = newValue;
        return value;
    }

    //function that changes the administrator, it can only be called by the current administrator, when changing admin, no previous administrator can call it
    function setNewAdmin(address newAdmin)
        external
        adminExchange
        returns (bool)
    {
        admin = newAdmin;
        return true;
    }

    // function that changes the exchange authorizer for the exchange by VULC token, this function can only be called by the current admin
    function setNewAuthorizer(address newAuthorizer)
        external
        adminExchange
        returns (bool)
    {
        authorizer = newAuthorizer;
        return true;
    }

    //this function withdraws all the bnb relected in this contract for the exchange fee and sends it to the sender in this case the admin
    function withdrawFee() external adminExchange {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    /*
    This function allows you to withdraw the vulc tokens to the administrator's wallet.
    */
    function tokenAdmin() external adminExchange {
       uint256 ammount = IERC20(ERC20_ADDRESS).balanceOf(address(this));
        IERC20(ERC20_ADDRESS).transfer(admin, ammount);
    }

    /*this function changes the status of the exchange, if "false" is sent the exchange will be closed no transaction can be executed
     if "true" is sent the exchange will be fully enabled
    */
    function setNewStatus(bool setStatus)
        external
        adminExchange
        returns (bool)
    {
        open = setStatus;
        return open;
    }

    /* 
    Function that executes the token collection which is saved in this contract, that function receives the amount that must be debited to the user, 
    and the amount that will be entered in virtual token, the latter only as data that is saved in the event, it is validated first that the user can pay the fee,
     then a transfer is made from the sender to the contract of the number of tokens, the event is emitted and the received value is returned
    */
    function exchangeByToken(uint256 tokenDebited, uint256 virtualDelivered)
        public
        payable
        returns (uint256)
    {
        require(open == true, "exchange disabled");
        require(
            msg.value == exchangeValue(),
            "user dont have suficients amount to pay gas for this transaction"
        );

        IERC20(ERC20_ADDRESS).transferFrom(
            msg.sender,
            address(this),
            tokenDebited
        );
        emit e_newExchangeforVirtualToken(
            msg.sender,
            tokenDebited,
            virtualDelivered
        );
        return (tokenDebited);
    }

    /**
     This function can only be called by the authorizer, it is the one that approves the amount that the user will receive for the exchange,
      first we validate that the user does not have a previous authorized amount or exchange without finishing, then we set the mapping of the wallet authorized 
      to withdraw to true, then we set the last mapping that places the amount authorized by the wallet
      */
    function preAuthorization(uint256 tokenToDeliver, address recipient)
        external
        authorizerExchange
    {
        require(open == true, "exchange disabled");
        require(!m_walletPreauth[recipient], "user previusly authorized");
        m_walletPreauth[recipient] = true;
        m_amountAuthorized[recipient] = tokenToDeliver;
    }

    /* 
    This function is the one that delivers the exchange tokens to the user, this function has the modifier security to avoid reetrancy and fallback calls, 
    first we validate that you can pay the fee, then we validate that it is authorized, after this for security we pass the authorization to false , 
    we save the amount authorized in the mapping in a local variable, and a transfer is made from this contract to the sender, t
    hen the mapping of the authorized amount is set to 0 and we return the amount delivered
    */
    function exchangeByVirtualToken()
        external
        payable
        security
        returns (uint256)
    {
        require(open == true, "exchange disabled");
        require(
            msg.value == exchangeValue(),
            "user dont have suficients amount to pay gas for this transaction"
        );
        require(
            m_walletPreauth[msg.sender],
            "the user has not made the pre-authorization"
        );
        m_walletPreauth[msg.sender] = false;
        uint256 ammount = m_amountAuthorized[msg.sender];
        IERC20(ERC20_ADDRESS).transfer(msg.sender, ammount);

        m_amountAuthorized[msg.sender] = 0;
        return (ammount);
    }

    ////// Public VIEW FUNCTIONS

    // current fee value
    function exchangeValue() public view returns (uint256) {
        return value;
    }

    //current exchange status
    function exchangeStatus() public view returns (bool) {
        return open;
    }

    //Function that returns the amount authorized to withdraw by a wallet
    function getAmountAuth(address wallet) public view returns (uint256) {
        return m_amountAuthorized[wallet];
    }
}