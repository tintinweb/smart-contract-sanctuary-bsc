/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT

// Test this contract will all taxes. Even try with decimal taxes. 

pragma solidity ^0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    // The owner on the clearing contract will be the owner here too. 

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public masterContract;
    address public underlyingCoin;

    uint256 public underlyingCoinTax;
    bool public taxDetermined;

    constructor(address _masterContract, address _underlyingCoin) {
        masterContract = _masterContract;
        underlyingCoin = _underlyingCoin;

        require(isContract(_underlyingCoin), "constructor: The address provided is not a smart contract.");

        // Set the name and symbol first
        IERC20Metadata coin = IERC20Metadata(_underlyingCoin);
         
        _symbol = string(abi.encodePacked("w", coin.symbol()));
        _name = coin.name();
        _decimals = coin.decimals();
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        if(msg.sender == masterContract) {
            _transfer(sender, recipient, amount);
            return true;
        } else {
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
                unchecked {
                    _approve(sender, _msgSender(), currentAllowance - amount);
                }
            }
            
            return true;
        }
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked { _approve(_msgSender(), spender, currentAllowance - subtractedValue); }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function isContract(address _addr) private view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function mint(uint256 amount) public {
        if(!taxDetermined) {
            firstMint(amount, msg.sender);
        } else {
            IERC20 underlying = IERC20(underlyingCoin);
            TransferHelper.safeTransferFrom(underlyingCoin, msg.sender, address(this), amount);

            // Total coin balance : Total wrapped tokens issued :: Actual additional coins minted : New wrapped tokens issued
            uint256 new_Wrapped_Tokens_issued = (_totalSupply * amount) / underlying.balanceOf(address(this));
            _mint(msg.sender, new_Wrapped_Tokens_issued);
        }
    }

    function redeem(uint256 amountToReceive) public {
        IERC20 underlying = IERC20(underlyingCoin);

        // Total coin balance: Total wrapped tokens issued :: Amount to receive : wrapped tokens burned
        uint256 new_wrapped_tokens_burned = (_totalSupply * amountToReceive) / underlying.balanceOf(address(this));
        _burn(msg.sender, new_wrapped_tokens_burned);
        TransferHelper.safeTransfer(underlyingCoin, msg.sender, amountToReceive);
    }

    function firstMint(uint256 amount, address from) internal {
        // This is the first mint. Determine the tax here and allow the first minter to only increments of 100. 
        require(amount % 100 == 0, "Mint error: Sorry man, the first mint can only be in increments of 100, as we need to calculate the transfer tax of this coin (if any).");
        IERC20 underlying = IERC20(underlyingCoin);

        uint256 balanceBeforeTransfer = underlying.balanceOf(address(this));
        TransferHelper.safeTransferFrom(underlyingCoin, from, address(this), amount);
        uint256 balanceAfterTransfer = underlying.balanceOf(address(this));

        uint256 amountReceived = balanceAfterTransfer - balanceBeforeTransfer;
        // Need to make a comparison between amount received and amount given in the parameter. That'll be the tax
        if(amountReceived < amount) {
            underlyingCoinTax = ((amount - amountReceived)/amount) * 100;
            taxDetermined = true;

            _mint(from, amount);
        } else if(amountReceived == amount) {
            // No tax
            taxDetermined = true;

            _mint(from, amount);
        }

        // If it's a fucked up coin, where amount received is more than amount. Then the coin is fucked up lol and nothing happens :)
    }

    function getMasterContract() external view returns(address) {
        return masterContract;
    }

    function getUnderlyingTokenBalance() external view returns(uint256) {
        return IERC20Metadata(underlyingCoin).balanceOf(address(this)) * (_balances[msg.sender]/_totalSupply);
    }

    // Maybe have a self destruct in case the coin is 1:1 and the coin doesn't have a tax + when it's whitelisted
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}