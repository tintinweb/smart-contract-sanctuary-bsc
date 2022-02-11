/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract SlotMachine is IERC20{
    using SafeMath for uint256;
    string private _name = "Smart Slot Machine";
    string private _symbol = "SSM";
    uint256 private _decimals = 18;

    address private _owner;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply = 10**10 * 10**_decimals;
    
    address[] Senderaddress;

    uint8 private Reward;
    uint private txfee;

    uint256 private _ticket;
    
    address private _winner;

    address marketaddress = address(0x4445D6355CB9D3E8Cb62C1DcCc7572b42F134dfd);
    
    uint256 private price;
    constructor()  payable{
      _owner = payable(msg.sender);
      _balances[address(this)] = _totalSupply;
      Reward = 5;
      _ticket =1000;
      txfee = 10;
      price = 100000;
      emit Transfer(address(0),_owner,_totalSupply);
    }
  
      function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

     function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _basicTransfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _basicTransfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(recipient!=address(this))
        {
           _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
           _balances[recipient] = _balances[recipient].add(amount);
           emit Transfer(sender, recipient, amount);
        }
        else
        {
           Recive(amount);
        }
       
        return true;
    }

    function Recive(uint256 amount) private returns(bool){
        uint256 Needamount = _ticket * 10**_decimals;
        require(amount != Needamount,"Need correct tickets !!!");

        _balances[msg.sender] = _balances[msg.sender].sub(amount,"Insufficient Balance");
        _balances[address(this)]=_balances[address(this)].add(amount);
        emit Transfer(msg.sender, address(this), amount);
        Senderaddress.push(msg.sender);
        if(Senderaddress.length >= Reward)
        {
           uint256 totalrewards = Needamount.mul(Reward);
           uint256 rewards_tx =  totalrewards.mul(txfee).div(100);
           uint256 winrewards =  totalrewards.sub(rewards_tx,"Insufficient Balance");
           
           _winner = Senderaddress[rand(Senderaddress.length)];
           _balances[_winner] = _balances[_winner].add(winrewards);
          
           _balances[marketaddress] = _balances[marketaddress].add(rewards_tx);   

           _balances[address(this)]=_balances[address(this)].sub(totalrewards,"Insufficient Balance");  

           emit Transfer(address(this), _winner, winrewards);        
           delete Senderaddress;
            
        }
        return true;
    }
    function rand(uint256 _length) private view returns(uint256) {  
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,msg.sender)));  
        return random%_length;  
    }
    function GetWinner()public view returns(address)
    {
        return _winner;
    }
    function SetReward(uint8 times) public returns(bool)
    {
        require (msg.sender==_owner,"Ownable: caller is not the owner");
        Reward = times;
        return true;
    }
    function Settickets(uint256 tickets) public returns(bool)
    {
        require (msg.sender==_owner,"Ownable: caller is not the owner");
        _ticket = tickets;
        return true;
    }
    function GetReward()public view returns(uint256)
    {
        return Reward*_ticket;
    }
    function SellTokens(uint256 amount) public  returns(bool)
    {       
        require(isContract(msg.sender), "Address: call to non-contract");
        require(amount > 0,"You need to send some tokens!");
        uint256 bnbdecimals = 10**18;
        uint256 tokendecimals = 10**_decimals;

        uint256 allowaceeth = address(this).balance.mul(tokendecimals).div(bnbdecimals);
        require(allowaceeth >= amount.div(price),"constract bnb balance not enough");
        
        _balances[msg.sender] = _balances[msg.sender].sub(amount,"Insufficient Balance");
        _balances[address(this)]=_balances[address(this)].add(amount);
       
        emit Transfer(msg.sender, address(this), amount);

        uint256 geteth = amount.div(price).mul(bnbdecimals).div(tokendecimals);
        payable(msg.sender).transfer(geteth);
        return true;
    }
    function BuyTokens() private returns(bool)
    {
        uint256 bnbdecimals = 10**18;
        uint256 tokendecimals = 10**_decimals;
        uint256 ethamountTobuy = msg.value.mul(tokendecimals).div(bnbdecimals);
        uint256 tokenamounttobuy = ethamountTobuy.mul(price);
        uint256 dexBalance = _balances[address(this)];
        require(ethamountTobuy > 0, "You need to send some bnb");
        require(dexBalance >= ethamountTobuy.mul(price), "Not enough tokens in the Constract");              
        _balances[address(this)] = _balances[address(this)].sub(tokenamounttobuy,"Insufficient Balance");
        _balances[msg.sender]=_balances[msg.sender].add(tokenamounttobuy);
        
        emit Transfer(address(this), msg.sender, tokenamounttobuy);
        return true;
    }
    function GetNumberofparticipants() public view returns (uint256)
    {
        return Senderaddress.length;
    } 
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    receive() external payable {
        BuyTokens();
    }
    fallback() external payable {}
}