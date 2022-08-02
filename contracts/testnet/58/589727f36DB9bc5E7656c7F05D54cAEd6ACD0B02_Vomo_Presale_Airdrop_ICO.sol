/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

pragma solidity 0.8.15;
    contract Vomo_Presale_Airdrop_ICO {
// Fields:
    string public constant name = "VomoVerse";
    string public constant symbol = "Vomo";
    uint public constant decimals = 18;
    uint public Presale_Price = 70921; // per 1 Ether
    uint actual_Presale_Price =Presale_Price-((Presale_Price/100)*1);
    uint256 public constant Token_Soft_Cap = 105000000000000000000000000;
    uint256 public constant Softcap_Price = 35587;
    uint256 public constant Token_Hard_Cap = 105000000000000000000000000;
    uint256 public constant Hardcap_Price= 17793;
    uint256 public constant Listing_Price =14416;
    enum State{
    Init,
    Running
    }
    uint256 public presaleBalance;
    uint256 public airdropBalance;
    uint256 public Presale_Start_Countdown;
    uint256 public Presale_End_Countdown;
    //uint numTokens;
    uint256 presaleSupply_;
    address funder1;
    address funder2;
    address funder3;
    address Development;
    address Marketing;
    address Community;
    address TokenStability;
    address _referral;
    State public currentState = State.Running;
    uint public Presale_initialToken = 0;
    uint public Airdrop_initialToken = 0; // amount of tokens already sold
    uint DropTokens;
// Gathered funds can be withdrawn only to escrow's address.
    address public escrow ;
    mapping (address => uint256) private balance;
    mapping (address => bool) ownerAppended;
    address[] public owners;

/// Modifiers:
    modifier onlyInState(State state){ require(state == currentState); _; }

/// Events:

    event presaleTransfer(address indexed from, address indexed to, uint256 _value);
    event referalTransfer(address indexed from, address indexed to, uint256 _value);
    event AirdropTransfer(address indexed from, address indexed to, uint256 _value);
    event Transfer(address indexed from, address indexed to, uint256 _value);

/// Functions:
    constructor(address _escrow, uint256 _Presale_Start_Countdown, uint256 _Presale_End_Countdown, address _funder1, address _funder2, address _funder3, address _Development, address _Marketing, 
    address _Community, address _TokenStability, uint _DropTokens) public {
    Presale_Start_Countdown = _Presale_Start_Countdown;
    Presale_End_Countdown = _Presale_End_Countdown;
    require(_escrow != address(0));
    escrow = _escrow;
    DropTokens = _DropTokens;
    presaleSupply_ = 3000000000000000000000000;
    funder1 = _funder1;
    funder2 = _funder2;
    funder3 = _funder3;
    Development = _Development;
    Marketing = _Marketing;
    Community = _Community;
    TokenStability =_TokenStability;
    balance[escrow] += DropTokens;
    balance[escrow] += presaleSupply_;
    }

    function buyTokens(address _buyer, address _referral) public payable onlyInState(State.Running) {
    require(_referral !=  _buyer);
    require(block.timestamp >= Presale_Start_Countdown, "Presale will Start Soon..");
    //require(block.timestamp <= Presale_End_Countdown, "Presale Date Exceed.");
    require(msg.value != 0);
    if(block.timestamp <= Presale_End_Countdown){
        uint buyerTokens = msg.value * actual_Presale_Price;
        uint reftokensVal = msg.value * Presale_Price;
        if (msg.value>=13152000000000000) {
            uint refToken = (reftokensVal/100)*4;
            uint actual_refToken =refToken-((refToken/100)*1);
            balance[_referral] += actual_refToken;
        emit referalTransfer(msg.sender, _referral,  refToken);
        }
        require(Presale_initialToken + buyerTokens <= presaleSupply_);

        balance[_buyer] += buyerTokens;
        
        Presale_initialToken += buyerTokens;
        balance[escrow] = presaleSupply_-Presale_initialToken;
        uint256 _presaleBalance = balance[escrow];
        presaleBalance = _presaleBalance;
        if(!ownerAppended[_buyer]) {
         ownerAppended[_buyer] = true;
         owners.push(_buyer);
        }
        
    emit presaleTransfer(msg.sender, _buyer,  buyerTokens);
    }
    uint Balance_funder1 = (msg.value/100)*15;
    uint Balance_funder2 = (msg.value/100)*5;
    uint Balance_funder3 = (msg.value/100)*5;
    uint Balance_Development = (msg.value/100)*35;
    uint Balance_Marketing = (msg.value/100)*25;
    uint Balance_Community = (msg.value/100)*5;
    uint Balance_TokenStability = (msg.value/100)*10;
          
   
    if(address(this).balance > 0) {
        payable (funder1).transfer(Balance_funder1);
        payable (funder2).transfer(Balance_funder2);
        payable (funder3).transfer(Balance_funder3);
        payable (Development).transfer(Balance_Development);
        payable (Marketing).transfer(Balance_Marketing);
        payable (Community).transfer(Balance_Community);
        payable (TokenStability).transfer(Balance_TokenStability);}

    

    }

    function AirDrop(address to, uint256 numDropTokens) public virtual  returns (bool) {
        require(msg.sender == escrow);
        require(numDropTokens <= DropTokens);
        require(Airdrop_initialToken + numDropTokens <= DropTokens);
        balance[to] += numDropTokens;
        Airdrop_initialToken += numDropTokens;
        balance[escrow]=DropTokens - Airdrop_initialToken;
        uint256 _airdropBalance = balance[escrow];
        airdropBalance = _airdropBalance;
        if(!ownerAppended[to]) {
         ownerAppended[to] = true;
         owners.push(to);
        }
         emit AirdropTransfer(msg.sender, to, numDropTokens);
        return true;
        
    }

/// @dev Returns number of tokens owned by given address.
/// @param _owner Address of token owner.
   function balanceOf(address _owner) public view virtual returns (uint256) {
        return balance[_owner];
    }

    address public owner;

    
// Transfer Ownership
    function Ownable() public {
    owner = msg.sender;
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _ ;
    }

    function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
    owner = newOwner;
    }
    }

// Default fallback function
    function fallback () public payable {
    buyTokens(msg.sender, _referral);
    }
    
}