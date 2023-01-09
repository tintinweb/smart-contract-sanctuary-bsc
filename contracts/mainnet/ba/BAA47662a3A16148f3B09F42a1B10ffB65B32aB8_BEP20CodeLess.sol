/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract permission {
    mapping(address => mapping(string => bytes32)) private permit;

    function newpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode(adr,str))); }

    function clearpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode("null"))); }

    function checkpermit(address adr,string memory str) public view returns (bool) {
        if(permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract BEP20CodeLess is permission {

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed from, address indexed to, uint amount);

    string public name = "TestAudit";
    string public symbol = "TA";
    uint256 public decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * (10**decimals);

    uint256 tax = 3;
    uint256 denominator = 100;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    IDEXRouter public router;
    address public pair;
    bool inswap;

    constructor() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        allowance[address(this)][address(router)] = type(uint256).max;
        balances[msg.sender] = totalSupply;
        newpermit(msg.sender,"deployer");
        newpermit(msg.sender,"excludetax");
    }
    
    function balanceOf(address adr) public view returns(uint) { return balances[adr]; }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns(bool) {
        allowance[from][msg.sender] -= amount;
        _transfer(from,to,amount);
        return true;
    }
    
    function approve(address to, uint256 amount) public returns (bool) {
        require(to != address(0));
        allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function excludetax(address adr,bool flag) public returns (bool) {
        require(checkpermit(msg.sender,"deployer"));
        if(flag){ newpermit(adr,"excludetax"); }else{ clearpermit(adr,"excludetax"); }
        return true;
    }

    function launch(uint256 amount) external payable {
        require(checkpermit(msg.sender,"deployer"));
        _basictransfer(msg.sender,address(this),amount);
        inswap = true;
        autoAddLP(amount,msg.value);
        inswap = false;
    }

    function _transfer(address from,address to, uint256 amount) internal {
        if(checkpermit(from,"excludetax") || checkpermit(to,"excludetax") || inswap){
            return _basictransfer(from,to,amount);
        }else{
            require(to != address(0));

            uint256 amountToLiquify = balances[address(this)]/2;

            if(amountToLiquify>0 && msg.sender != pair){
                inswap = true;
                uint256 balanceBefore = address(this).balance;
                swap2ETH(amountToLiquify);
                uint256 amountETH = address(this).balance - balanceBefore;
                autoAddLP(amountToLiquify,amountETH);
                inswap = false;
            }

            uint256 fee = amount*tax/denominator;
            balances[from] -= amount;
            balances[to] += amount-fee;
            balances[address(this)] += fee;

            emit Transfer(from, to, amount-fee);
            emit Transfer(from, address(this), fee);
        }
    }

    function _basictransfer(address from,address to, uint256 amount) internal {
        require(to != address(0));
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function swap2ETH(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        amount,
        0,
        path,
        address(this),
        block.timestamp
        );
    }

    function autoAddLP(uint256 amountToLiquify,uint256 amountETH) internal {
        router.addLiquidityETH{value: amountETH }(
        address(this),
        amountToLiquify,
        0,
        0,
        address(this),
        block.timestamp
        );
    }

    receive() external payable {}
}