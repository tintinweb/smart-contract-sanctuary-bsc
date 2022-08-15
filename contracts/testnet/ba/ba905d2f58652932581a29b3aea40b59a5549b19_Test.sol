// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./treasuryLoked.sol";
import "./ABDKMathQuad.sol";



// Declaration of the contract
contract Test is  ERC20 {

    LockTest newContract;
    Test token;
    uint256 USDTReceived=0;
    uint256 PreSaleTokens=100000;
    using ABDKMathQuad for bytes16;
    bool isTransferring = false;

// Address evidence
    address[] private addresses;
// Address used for burn
    address burnAddress = 0x3e8FA613AB7dBc78900a36Ce6A9fa2A7CFe5EE61;
    address addressContractor = _msgSender();
// Mapping Contract
    
    mapping(address => LockTest) private _contractLink;
    mapping(address => uint256) private _sentUSDT;
    mapping(address => bool) private _receivedTreasury;
    mapping(address => uint256) private _failedToSent;
    mapping(address => uint256) private _lockedTreasury;


    
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

// Transfer function override to decline transactions from burnAddress
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) 
    {
        address owner = _msgSender();
        if(owner == burnAddress){
            return false;
        }
        else
        {
            _transfer(owner, to, amount);
            return true;
        }
    }

// Burn function for burnAddress only
    function burnTreasury(uint256 amount) public returns(
        string memory,
        uint256,
        string memory,
        address
    ) {
        address sender = _msgSender();
        if (sender == burnAddress)
        {
           require(sender == burnAddress, "The burn should be processed from burn address."); 
            _burn(sender,amount);
            return(
                "The amount below was burned with success:",
                amount,
                "The address used to burn was:",
                sender
            );
        }
        else
            revert('The burn was not processed');
    }

// Burn function for public (everyone can burn as they please)
    function publicBurnTreasury (uint256 amount) public returns(string memory, uint256) {
        address sender = _msgSender();
        require ( sender != getTokenAddressContractor() && sender != burnAddress, "This is the public function for burn");
        _burn(sender,amount);
        return(
            "You hace successfully burned the below amount:",
            amount
        );
    }

// Get the token contractor address  
    function getTokenAddressContractor() public view returns(address) {
        return addressContractor;
    }

// Lock treasury
// This function may be called only by the token contractor address

    event treasuryLockEvent(address,uint256);
    function treasuryLock(
        address _beneficiary,
        uint256 amount
    ) public returns(
        string memory, 
        uint256, 
        string memory, 
        address
        ) {

        require(isTransferring == false, "Rentrancy Detected");
        isTransferring = true;
        require( _beneficiary != address(0), "Please insert the beneficiary address.");
        address from = _msgSender();
        require( from == getTokenAddressContractor(), "Only token address contractor can lock Treasury.");
        require(from != burnAddress, "Burn address can not lock treasury." );

        if (_contractLink[_beneficiary] == newContract)
            _contractLink[_beneficiary] = new LockTest(token,_beneficiary);

        _transfer(from, _contractLink[_beneficiary].getAddress() ,amount);
        _lockedTreasury[_beneficiary]=balanceOf(_contractLink[_beneficiary].getAddress());
        isTransferring = false;
        emit treasuryLockEvent(_beneficiary,amount);
         return (
            "Existing contract received amount:",
            amount,
          "Beneficiary address:",
          _beneficiary
        );
        
    }

    function transfer_LKTreasury(address from ,address _beneficiary,uint256 amount, bool state) public
    {
        if(state == true)
           _transfer(from, _contractLink[_beneficiary].getAddress() ,amount) ;

    }

// Get the LkTreasury amount avaialble from main contract
    function getLkTresuryBalance() private view returns(uint256)
    {
        return _lockedTreasury[msg.sender];
    }
// Get the release date of the token
    function getRealeaseTime(address beneficiary) public view returns(
        string memory,
        uint
        ) {  

        require( _contractLink[beneficiary] != newContract, "No link between accounts found." );
        return (
            "Realease time in UNIXTIME:",
            _contractLink[beneficiary].getRealeaseTime()
        );
    }

// Show the LKTreausry balanced for specific beneficiary 
    function showLKTreasuryBalanceLocked(address beneficiary) public view returns(
        string memory,
        uint256
        ) {

        require( beneficiary != address(0), "Please insert the beneficiary address.");
        require( _contractLink[beneficiary] != newContract, "No link between accounts found." );
        address linkedContractAddress = _contractLink[beneficiary].getAddress();
        return (
            "Your LKTreasury balance is:",
            balanceOf(linkedContractAddress)
        );
    }

// Realease the LKTreasury for specific beneficiry
    function releaseLKTreasury() public returns(string memory,uint256,string memory,address) {
        require(isTransferring == false, "Rentrancy Detected");
        isTransferring = true;

        require( _contractLink[msg.sender] != newContract, "No link between accounts found." );
        require( block.timestamp > _contractLink[msg.sender].getRealeaseTime(), "The release time was not reached.");
        uint256 amount = balanceOf(_contractLink[msg.sender].getAddress());
        
        _lockedTreasury[msg.sender]=0;
        _transfer(_contractLink[msg.sender].getAddress(),msg.sender,amount);
      if ((balanceOf(msg.sender)-amount) == balanceOf(msg.sender)){
        _contractLink[msg.sender].setBalance();
        isTransferring = false;
        return (
            "The amount below was unlocked:",
            amount,
            "Treausry was released to address",
            msg.sender
        );
        }
        else
        {
            _lockedTreasury[msg.sender]= amount;
            isTransferring = false;
        return (
            "The amount below failed to be tranfered:",
            amount,
            "Treausry was not released to address",
            msg.sender
        );
        }
    }

    // Realease the LKTreasury early
    function releaseLKTreasuryEarly() public returns(string memory,uint256,string memory,address) {
        require( _contractLink[msg.sender] != newContract , "No link between accounts found." );
        require(isTransferring == false, "Rentrancy Detected");
        isTransferring = true;

        address linkedContractAddress = _contractLink[msg.sender].getAddress();
        uint256 amountRealeaseBeneficiary = balanceOf(linkedContractAddress) /2 /2 /2 /2 *7;
        uint256 amountRealeaseMainAddress = balanceOf(linkedContractAddress) - amountRealeaseBeneficiary;

        require( 
            amountRealeaseMainAddress + amountRealeaseBeneficiary ==  balanceOf(linkedContractAddress),
            "The amount calculated is not correct." 
            );

    // Transfering the LKTreausry to beneficiary user
        _transfer(linkedContractAddress,msg.sender,amountRealeaseBeneficiary);
    // Transfering the rest of LKTreasury back to main address
        _transfer(linkedContractAddress,getTokenAddressContractor(),amountRealeaseMainAddress);
        isTransferring = false;
        return (
            "The amount below was unlocked:",
            amountRealeaseBeneficiary,
            "Treausry was released to address:",
            msg.sender
        );
    }

// View LKTreasury early redeem amount
    function getEarlyLKTreasuryRealeaseAmount(address beneficiary) public view returns(
        string memory,
        uint256,
        string memory,
        uint256
        ) {

        require( _contractLink[beneficiary] != newContract , "No link between accounts found." );
        address linkedContractAddress = _contractLink[beneficiary].getAddress();
        uint256 amountRealeaseBeneficiary = balanceOf(linkedContractAddress) /2 /2 /2 /2 *7;
        uint256 amountRealeaseMainAddress = balanceOf(linkedContractAddress) - amountRealeaseBeneficiary;

        return (
            "The amount which will be reverted to mainAddress is:",
            amountRealeaseMainAddress,
            "The amount which will be reverted to beneficiary is:",
            amountRealeaseBeneficiary
        );
    }

// Get beneficiary contract
    function getLKTreausyContract(address beneficiary) public view returns(address) {
        require( _contractLink[beneficiary] != newContract , "No link between accounts found." );
        return _contractLink[beneficiary].getAddress();
    }


// Accept USDT

event ValueSent(address user, uint amount);
receive() payable external {
    USDTReceived+=USDTReceived;
    emit ValueSent(msg.sender, msg.value);
    if(_sentUSDT[msg.sender] > 0 ){
        _sentUSDT[msg.sender]+=_sentUSDT[msg.sender];
    }
    else
    {
        _sentUSDT[msg.sender]= msg.value;
    }
}

// Get ValueSent

    function getPreSaleUSDTAmount(address beneficiary) private view returns(uint256){
        return _sentUSDT[beneficiary];
    }

    function showPreSaleUSDTAmount() public view returns(string memory,uint256) {
         return (
            "You used the amoune below in Pre-Sale:",
            getPreSaleUSDTAmount(msg.sender)
        );   
    }

    function getTotalUSDTPreSale() private view returns(uint256){
        return USDTReceived;
    }

    function showUSDTPreSaleTOTAL() public view returns(string memory,uint256) {
        return (
            "The total amount of USDT in Pre-Sale is:",
            USDTReceived
        );
    }

//

    
    function getAddressCount() public view returns(uint) {
        return addresses.length;
    }

    function getReceiveTreasuryBool() private view returns(bool){
        return _receivedTreasury[msg.sender];
    }

    function getAddressAtRow(uint row) public view returns(address) {
        return addresses[row];
        }


    event distributionEvent(string message,address user, uint256 amount);
    function distributePreSaleTokens() public returns(string memory){
        address from = _msgSender();
        require( from == getTokenAddressContractor(),"Only token address contractor can execute the distribution of tokens.");
        bytes16 pricePerTreasury16;
        bytes16 totalUSDTPresale16=ABDKMathQuad.fromUInt(getTotalUSDTPreSale());
        bytes16 PreSaleTokens16=ABDKMathQuad.fromUInt(PreSaleTokens);
        bytes16 _sentUSDT16;
        bytes16 _receiveTreasury16;
        uint256 amountLKTreasuryToReceive;
        pricePerTreasury16=ABDKMathQuad.div(totalUSDTPresale16,PreSaleTokens16);
        for(uint i=1 ;i<= getAddressCount();i++)
        {
            require( getReceiveTreasuryBool() != false , "This account already received LKTresury." );
            _sentUSDT16=ABDKMathQuad.fromUInt(getPreSaleUSDTAmount(addresses[i]));
            _receiveTreasury16=ABDKMathQuad.mul(_sentUSDT16,pricePerTreasury16);
            amountLKTreasuryToReceive=ABDKMathQuad.toUInt(_receiveTreasury16);
            treasuryLock(addresses[i],amountLKTreasuryToReceive);
            _receivedTreasury[addresses[i]]=true;
            emit distributionEvent("The transaction below was done:",addresses[i],amountLKTreasuryToReceive);
        }
    return "Function executed with success.";

    }

    constructor() ERC20("Test", "TS") {
        _mint(msg.sender, 200000000 );
        
    }

}