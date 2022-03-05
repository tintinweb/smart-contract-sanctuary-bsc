// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Libraries.sol";

contract MetaOfWorld {
    string public name = "MetaOfWorld";
    string public symbol = "MOW";
    uint256 public totalSupply = 300000000000000000000000000; // 
    uint8 public decimals = 18;
    address public teamWallet; // owner.
    address public marketingWallet; // adress wallet marketing.
    address private firstPresaleContract; // adress wallet first presale.
    address private secondPresaleContract; // adress wallet second presale.
    address private teamVestingContract; // adress wallet vesting.
    IUniswapV2Router02 router; // Router.
    address private pancakePairAddress; // adress par.
    uint public liquidityLockTime = 1095 days; // time locked liquidity.
    uint public liquidityLockCooldown;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(address _teamWallet, address _marketingWallet, address _firstPresaleContract, address _secondPresaleContract, address _teamVestingContract) {
        teamWallet = _teamWallet;
        marketingWallet = _marketingWallet;
        firstPresaleContract = _firstPresaleContract;
        secondPresaleContract = _secondPresaleContract;
        teamVestingContract = _teamVestingContract;
        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pancakePairAddress = IPancakeFactory(router.factory()).createPair(address(this), router.WETH());

        uint _firstPresaleTokens = 10000000000000000000000000;
        uint _secondPresaleTokens = 20000000000000000000000000;
        uint _teamVestingTokens = 45000000000000000000000000;
        uint _marketingTokens = 15000000000000000000000000;
        uint _contractTokens = totalSupply - (_teamVestingTokens + _marketingTokens + _firstPresaleTokens + _secondPresaleTokens);

        balanceOf[firstPresaleContract] = _firstPresaleTokens;
        balanceOf[secondPresaleContract] = _secondPresaleTokens;
        balanceOf[teamVestingContract] = _teamVestingTokens;
        balanceOf[marketingWallet] = _marketingTokens;
        balanceOf[address(this)] = _contractTokens;
    }

    modifier onlyOwner() {
        require(msg.sender == teamWallet, 'You must be the owner.');
        _;
    }

    /**
     * @notice Function transfer.
     * @param _to adress to.
     * @param _value tokens to transfer.
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @notice sss
     * @param _owner ssss
     * @param _spender sxs
     */
    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return _allowances[_owner][_spender];
    }

    /**
     * @notice  allowance.
     * @param _spender Adress wallet
     * @param _addedValue Amount.
     */
    function increaseAllowance(address _spender, uint256 _addedValue) public virtual returns (bool) {
        _approve(msg.sender, _spender, _allowances[msg.sender][_spender] + _addedValue);

        return true;
    }

    /**
     * @notice l allowance.
     * @param _spender pay tokens.
     * @param _subtractedValue amount.
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {
            _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
        }

        return true;
    }

    /**
     * @notice interna _approve.
     * @param _spender adress aprove.
     * @param _value tokens aprove.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _approve(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @notice aprove.
     * @param _owner adrees allowance.
     * @param _spender adrees spender.
     * @param _amount adrees amount.
     */
    function _approve(address _owner, address _spender, uint256 _amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }

    /**
     * @notice transfer to from.
     * @param _from adress from.
     * @param _to adress to.
     * @param _value tokens transfer.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= _allowances[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        _allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    /**
     * @notice Public burn tokens.
     * @param _amount  burn tokens.
     */
    function burn(uint256 _amount) public virtual {
        _burn(msg.sender, _amount);
    }

    /**
     * @notice burn tokens.
     * @param _account adress burn.
     * @param _amount burn tokens.
     */
    function _burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), 'No puede ser la direccion cero.');
        require(balanceOf[_account] >= _amount, 'La cuenta debe tener los tokens suficientes.');

        balanceOf[_account] -= _amount;
        totalSupply -= _amount;

        emit Transfer(_account, address(0), _amount);
    }
    
    /**
     * @notice add liquidity.
     * @param _tokenAmount Tokens liquidity.
     */
    function addLiquidity(uint _tokenAmount) public payable onlyOwner {
        require(_tokenAmount > 0 || msg.value > 0, "Insufficient tokens or BNBs.");
        require(IERC20(pancakePairAddress).totalSupply() == 0);

        _approve(address(this), address(router), _tokenAmount);

        liquidityLockCooldown = block.timestamp + liquidityLockTime;

        router.addLiquidityETH{value: msg.value}(
            address(this),
            _tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    /**
     * @notice remove liquidity.
     */
    function removeLiquidity() public onlyOwner {
        require(block.timestamp >= liquidityLockCooldown, "Locked");

        IERC20 liquidityTokens = IERC20(pancakePairAddress);
        uint _amount = liquidityTokens.balanceOf(address(this));
        liquidityTokens.approve(address(router), _amount);

        router.removeLiquidityETH(
            address(this),
            _amount,
            0,
            0,
            teamWallet,
            block.timestamp
        );
    }
}