// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";

contract ShubhamToken is ERC20, Ownable {

    address private liquidityWallet;
    address private devWallet;

    address[] private holders;

    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    IUniswapV2Factory public  factory;

    address public pair; 

    //bool private recursive= false; /// Avoid to infinite call to transfer function from Distribute rewards;
 

    constructor(address _liquidityWallet, address _devWallet) ERC20("ShubhamToken", "STP21") {
        _mint(msg.sender, 500000 * 10 ** decimals());
        holders.push(msg.sender);
        liquidityWallet= _liquidityWallet;
        devWallet= _devWallet;
        factory = IUniswapV2Factory(uniswapRouter.factory());
        pair = factory.createPair(address(this), uniswapRouter.WETH());
    }

    function getHolders() public view returns(address[] memory)
    {
        return holders;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        if(balanceOf(to)==0&&to!=pair)
        {
            holders.push(to);
        }
        taxCollecteor(owner,to,amount);
        if(balanceOf(owner)==0)
        {
            removeFromArray(owner);
        }
        return true;
    }

    function setPair(address _pair) public {
        pair = _pair;
    }
    function getbalance() public view returns(uint256) {
        return address(this).balance;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        if(balanceOf(to)==0&&to!=pair)
        {
            holders.push(to);
        }
        _spendAllowance(from, spender, amount);
        taxCollecteor(from,to, amount);
         if(balanceOf(from)==0)
        {
            removeFromArray(from);
        }
        return true;
    }

    function taxCollecteor(address from, address to , uint256 amount) internal {
        if(from==address(this)&& to == pair)
        {
            finaltransfer(from, to, amount, amount);
        }
        else if(from == pair && to == address(this))
        {
            finaltransfer(from, to, amount, amount);
        }
        else if(from == owner()&& to == pair)
        {
            finaltransfer(from, to, amount, amount);
        }
        else if(from == pair && to == owner() )
        {
            finaltransfer(from, to, amount, amount);
        }
        else 
        {
            uint256 tax = calculateTax(amount);
            uint256 amountaftertax = amount-tax;
            finaltransfer(from, to , amount, amountaftertax);
            DistributeTax(tax);
        }
    }

    function finaltransfer(address from,address to,uint256 amount, uint256 amountaftertax) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amountaftertax;
        if(amount!=amountaftertax)
        {
            _balances[address(this)]+=(amount-amountaftertax);
        }
        
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function chkSwap(uint256 tax) public {
        address[] memory path;
        path = new address[](2);
        path[0]= address(this);
        path[1] = uniswapRouter.WETH();
       // uint256 initialBalance = address(this).balance;
        _approve(address(this), address(uniswapRouter), tax);
        uniswapRouter.swapExactTokensForETH(tax,0, path, address(this), block.timestamp+360);
    }

    function DistributeTax(uint256 tax) public {
        address[] memory path;
        path = new address[](2);
        path[0]= address(this);
        path[1] = uniswapRouter.WETH();
        uint256 initialBalance = address(this).balance;
        _approve(address(this), address(uniswapRouter), tax);
        uniswapRouter.swapExactTokensForETH(tax,0, path, address(this), block.timestamp);
        uint256 balance = address(this).balance - initialBalance;
        uint256 holderShare = balance/2;
        payable(liquidityWallet).transfer(holderShare/2);
        payable(devWallet).transfer(holderShare/2);
        uint256 shareperHolder = holderShare/holders.length;
        for(uint i =0 ; i<holders.length; i++)
        {
            payable(holders[i]).transfer(shareperHolder);
        }
    }

    function removeFromArray(address user) private {
        uint256 index;
        for(uint256 i =0 ; i< holders.length; i++){
            if(holders[i]== user)
            {
                index = i;
                break; 
            }
        }
        holders[index]= holders[holders.length-1];
        holders.pop();
    }

    function calculateTax(uint256 amount) private pure returns(uint256){
        return (amount*12)/100;
    }

    receive ()external payable{}
    fallback() external payable{}
}