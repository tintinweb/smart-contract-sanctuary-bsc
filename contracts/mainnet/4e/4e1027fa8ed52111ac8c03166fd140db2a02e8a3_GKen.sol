// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./GKenERC20.sol";
import "./UniSwap.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";


contract GKen is GKenERC20, ReentrancyGuard {
    using SafeMath for uint256;

    // pancakeswap
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // exclude from fees
    mapping (address => bool) private _isExcludedFromFees;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    address public PRESALE_ADDRESS            = 0x708ef6E756240af2397D5Cecb6C3066DAA67A5d7; 
    address public LP_ADDRESS                 = 0xc5B2Fc2E11d2008339812f8cE94513f10B4327BC;
    address public MARKETING_ADDRESS          = 0xc450827d10368c2dC0c922deE4A65dBbCD3C4905;
    address public PARTNERS_ADVISORS_ADDRESS  = 0x70d673345DD4Ff8CC8a77d7b77732a7BBC756a21;
    address public DEV_ADDRESS                = 0x4A38F7b351B093536c9C527B08fF1d3508C1A76d;
    address public PRIVATESALE_ADDRESS        = 0xB178dA6F5FBa03732568374f5c1402d4B5E48955;
    address public REWARD_POOL_ADDRESS        = 0xF8848562B41b031E625755455d00CAE3f942c8F5;

    address public TAX_ADDRESS                = 0x5F700413656931cc17205FBb89f33c72410D7105;

    constructor(
        string memory name, 
        string memory symbol,
        address pancakeRouterAddress
    ) GKenERC20(name, symbol) {
        
        uint256 decimal = 10**decimals();
        uint256 totalSupply = 10 ** 9 * decimal ;

        _mint(PRESALE_ADDRESS           , (totalSupply * 15).div(100)); // 15%
        _mint(LP_ADDRESS                , (totalSupply * 15).div(100)); // 15% 
        _mint(MARKETING_ADDRESS         , (totalSupply * 10).div(100)); // 10%
        _mint(PARTNERS_ADVISORS_ADDRESS , (totalSupply * 3).div(100));  // 3%
        _mint(DEV_ADDRESS               , (totalSupply * 7).div(100));  // 7%
        _mint(PRIVATESALE_ADDRESS       , (totalSupply * 10).div(100)); // 10%
        _mint(REWARD_POOL_ADDRESS       , (totalSupply * 40).div(100)); // 40%

        // exclude from fees 
        excludeFromFees(owner(), true);
        excludeFromFees(PRESALE_ADDRESS, true);         
        excludeFromFees(LP_ADDRESS, true);          
        excludeFromFees(MARKETING_ADDRESS, true);   
        excludeFromFees(PARTNERS_ADVISORS_ADDRESS, true);       
        excludeFromFees(DEV_ADDRESS, true);             
        excludeFromFees(PRIVATESALE_ADDRESS, true);             
        excludeFromFees(REWARD_POOL_ADDRESS, true);               
        excludeFromFees(TAX_ADDRESS, true);

        excludeFromFees(address(this), true);
    
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pancakeRouterAddress);
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        
        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(uniswapV2Router), ~uint256(0));

    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        if(amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }

        uint256 transferFeeRate = recipient == uniswapV2Pair ? sellFeeRate : (sender == uniswapV2Pair ? buyFeeRate : 0);

        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) {
            takeFee = false;
        }
        if (
            transferFeeRate > 0 &&          // if transfer fee rate is greater than 0
            sender != address(this) &&      // and sender is not this contract address
            recipient != address(this) &&   // and recipient is not this contract address
            takeFee                         // and take fees
        ) {                                 // then deduct fee from the amount should be sent

            uint256 _fee = amount.mul(transferFeeRate).div(100);

            if(recipient == uniswapV2Pair) {                    // distribute sell fee
                super._transfer(sender, TAX_ADDRESS, _fee);
            } else if (sender == uniswapV2Pair) {               // distribute buy fee
                super._transfer(sender, TAX_ADDRESS, _fee);
            }  
            amount = amount.sub(_fee);
        }

        super._transfer(sender, recipient, amount);
    }

     
    // receive eth from uniswap swap
    receive() external payable {}  

    // --------------- FEE EXCLUSION AND INCLUSION   --------------- 
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    
    // setter for address
    function validateAddress(address addr) private pure {
        require(addr != address(0), "0x is not accepted here");
    }

    function setTaxAddress(address addr) external onlyOwner {
        validateAddress(addr);
        TAX_ADDRESS = addr;
    }
}