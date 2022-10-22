// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./treasuryLoked.sol";
import "./ABDKMathQuad.sol";
import "./receiveUSDT.sol";

// Declaration of the contract
contract Test is  ERC20 {

    LockTest newContract;
    USDTContract usdtContract;
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


// Decimals Function   
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

// Transfer function override to decline transactions from burnAddress
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) 
    {
        reEntrancy();
        isTransferring=true;
        address owner = _msgSender();
        require( owner != burnAddress,"Failed");
        _transfer(owner, to, amount);
        isTransferring=false;
        return true;
    }

// Burn function for burnAddress only
event burnTS(string,uint256);
    function burnTreasury(uint256 amount) public returns(bool) {
        require(msg.sender == burnAddress, "Use burn address.");
        reEntrancy();
        isTransferring=true;
        _burn(msg.sender,amount);
        isTransferring=false;
        emit burnTS("Burned:",amount);
        return true;
    }

// Burn function for public (everyone can burn as they please)
    function publicBurnTreasury (uint256 amount) public returns(string memory, uint256) {
        address sender = _msgSender();
        require ( sender != getTokenAddressContractor() && sender != burnAddress, "Public burn");
        _burn(sender,amount);
        return(
            "Burned:",
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
    ) public returns(bool) {

        require( _beneficiary != address(0), "Address missing.");
        address from = _msgSender();
        reEntrancy();
        isTransferring = true;
        require( from == getTokenAddressContractor(), "Admin required.");
        require(from != burnAddress, "Execute as Admin." );
        LockTest _contract = _contractLink[_beneficiary];
        if (_contract == newContract)
            _contract = new LockTest(token,_beneficiary);

        _transfer(from, _contract.getAddress() ,amount);
        _lockedTreasury[_beneficiary]=balanceOf(_contract.getAddress());
        isTransferring = false;
        emit treasuryLockEvent(_beneficiary,amount);
         return true;
    }

// Rentrancy
    function reEntrancy() private view
    {
       require(isTransferring == false, "Rentrancy Detected"); 
    }

// Link check
function checkLinkLK(address adr) private view
{
    require( _contractLink[adr] != newContract, "Link not found." ); 
}


// Get the LkTreasury amount avaialble from main contract
    function getLkTresuryBalance() private view returns(uint256)
    {
        return _lockedTreasury[msg.sender];
    }
// Get the release date of the token
    function getReleaseTime(address beneficiary) public view {  

        checkLinkLK(beneficiary);
        _contractLink[beneficiary].getReleaseTime();
    }

// Show the LKTreausry balanced for specific beneficiary 
    function showLKTreasuryBalanceLocked(address beneficiary) public view returns(
        string memory,
        uint256
        ) {

        require( beneficiary != address(0), "Address missing.");
        checkLinkLK(beneficiary);
        address linkedContractAddress = _contractLink[beneficiary].getAddress();
        return (
            "LKTreasury balance:",
            balanceOf(linkedContractAddress)
        );
    }


event eventLog(string,address, uint);
// Realease the LKTreasury for specific beneficiry
    function releaseLKTreasury() public returns(string memory) {
        reEntrancy();
        isTransferring = true;
        address _beneficiaryContract=_contractLink[msg.sender].getAddress();
        checkLinkLK(msg.sender);
        require( block.timestamp > _contractLink[msg.sender].getReleaseTime(), "The release time was not reached.");
        uint256 amount = balanceOf(_beneficiaryContract);
        
        _lockedTreasury[msg.sender]=0;
        _transfer(_beneficiaryContract,msg.sender,amount);
        _contractLink[msg.sender].setBalance();
        isTransferring = false;
        emit eventLog("Treasury released to",msg.sender,amount);
        return "Treasury released.";
    }

    // Realease the LKTreasury early
    function releaseLKTreasuryEarly() public returns(string memory,uint256) {
        checkLinkLK(msg.sender);
        reEntrancy();
        isTransferring = true;

        address linkedContractAddress = _contractLink[msg.sender].getAddress();
        uint256 amountRB = balanceOf(linkedContractAddress) /2 /2 /2 /2 *7;
        uint256 amountRM = balanceOf(linkedContractAddress) - amountRB;

        require( 
            amountRM + amountRB ==  balanceOf(linkedContractAddress),
            "Unexpected error." 
            );

    // user
        _transfer(linkedContractAddress,msg.sender,amountRB);
    // main
        _transfer(linkedContractAddress,getTokenAddressContractor(),amountRM);
        isTransferring = false;
        return (
            "Unlocked TS:",
            amountRB
        );
    }

// Get beneficiary contract
    function getLKTreausyContract(address beneficiary) public view returns(address) {
        checkLinkLK(msg.sender);
        return _contractLink[beneficiary].getAddress();
    }


// Accept USDT


event ValueSent(address user, uint amount);
receive() payable external {
    emit ValueSent(msg.sender, msg.value);
}

    
    function preSaleBuyLKTreasury( uint256 _amount) public{
        IERC20 _token = IERC20(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7));
        require(_amount <= _token.balanceOf(msg.sender),"Insuficient funds.");
        _sentUSDT[msg.sender] = _amount;
        _token.transfer(getTokenAddressContractor(),_amount);
        USDTReceived+=_amount;
    }

    function Compensate1Year(IERC20 _token,uint256 amount) public
    {
        uint256 erc20Balance= balanceOf(address(this));
        require(amount <= erc20Balance,"Insuficient funds.");
        _token.transfer(getTokenAddressContractor(),amount);
        _sentUSDT[msg.sender]=amount;
    }


// Get ValueSent
    function getPreSaleUSDTAmount(address beneficiary) public view returns(uint256){
        return _sentUSDT[beneficiary];
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



    event distributionEvent(address user, uint256 amount);
    function distributePreSaleTokens() public returns(bool){
        address from = _msgSender();
        require( from == getTokenAddressContractor(),"Admin required.");
        bytes16 pricePerTreasury16;
        bytes16 totalUSDTPresale16=ABDKMathQuad.fromUInt(getTotalUSDTPreSale());
        bytes16 PreSaleTokens16=ABDKMathQuad.fromUInt(PreSaleTokens);
        bytes16 _sentUSDT16;
        bytes16 _receiveTreasury16;
        uint256 amountLKTreasuryToReceive;
        pricePerTreasury16=ABDKMathQuad.div(totalUSDTPresale16,PreSaleTokens16);
        for(uint i=1 ;i<= getAddressCount();i++)
        {
            require( getReceiveTreasuryBool() != false , "LKTresury redeemed." );
            _sentUSDT16=ABDKMathQuad.fromUInt(getPreSaleUSDTAmount(addresses[i]));
            _receiveTreasury16=ABDKMathQuad.mul(_sentUSDT16,pricePerTreasury16);
            amountLKTreasuryToReceive=ABDKMathQuad.toUInt(_receiveTreasury16);
            treasuryLock(addresses[i],amountLKTreasuryToReceive);
            _receivedTreasury[addresses[i]]=true;
            emit distributionEvent(addresses[i],amountLKTreasuryToReceive);
        }
    return true;

    }

    constructor() ERC20("Test", "TS") {
        _mint(msg.sender, 200000000 );
        
    }

}