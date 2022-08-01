// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";

interface InviterLike {
    function inviter(address) external view returns (address);
    function setLevel(address,address) external;
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
contract eatNewToken is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "eatNewToken/not-authorized");
        _;
    }
    InviterLike public eatInviter = InviterLike(0x392c1bdD4f0f94cF7C36069FEF3a0790AeFAF319);
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public operationAddress = 0xc711D92F05ADCF8d0548829d6AD835a8548a9B78;
    address public LPpool = 0xc87c6DC93AE89572cdeaF98663EDe646505C3890;
    address public NFTpool = 0x0473396Ba10568409088AF9192a197E4CBC1973E;
    address public backLP;
    uint256 public swapTokensAtAmount = 500 * 1E18;

    mapping(address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
   
    constructor() public ERC20("eatNewToken", "eat") {

        wards[msg.sender] = 1;
        excludeFromFees(owner(), true);
        excludeFromFees(operationAddress, true);
        _mint(operationAddress, 150000 * 1e18);
    }
	function setVariable(uint256 what, address ust) external auth{
        if (what == 1) operationAddress = ust;
        if (what == 2) eatInviter = InviterLike(ust);
        if (what == 3) NFTpool = ust;
        if (what == 4) LPpool = ust;
        if (what == 5) backLP = ust;
	}
    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "eatNew: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "eatNew: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (eatInviter.inviter(to) == address(0) && balanceOf(to) == 0) eatInviter.setLevel(to,from);
        if (amount <= 1E18) {
            super._transfer(from, to, amount);
            return;
        }
 
		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && from != owner() && to != owner()) {
            if (totalSupply().sub(balanceOf(deadWallet)) > 5*1E22) {
                uint256 burnTokens = contractTokenBalance.mul(2).div(5);
                super._transfer(address(this),deadWallet,burnTokens);
            }
            uint256 NFTTokens = contractTokenBalance.mul(1).div(5);
            super._transfer(address(this),NFTpool,NFTTokens);
            super._transfer(address(this),backLP,NFTTokens);
            IUniswapV2Pair(backLP).sync();

            uint256 LPTokens = balanceOf(address(this));
            super._transfer(address(this),LPpool,LPTokens);
        }

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
        	uint256 fees = amount.mul(6).div(100);
            super._transfer(from, address(this), fees);
            uint256 referralBonuses = amount.mul(1).div(100);
            address dst;
            if(automatedMarketMakerPairs[from]) dst = to;
            else dst = from;
            address _referrer = eatInviter.inviter(dst);
            if(_referrer == address(0) || _referrer.isContract()) _referrer = operationAddress;
            super._transfer(address(this), _referrer, referralBonuses);
            amount = amount.sub(fees);
        }
        super._transfer(from, to, amount);       
    }
    
    function withdraw(address asses, uint256 amount, address ust) public auth {
        IERC20(asses).transfer(ust, amount);
    }

}