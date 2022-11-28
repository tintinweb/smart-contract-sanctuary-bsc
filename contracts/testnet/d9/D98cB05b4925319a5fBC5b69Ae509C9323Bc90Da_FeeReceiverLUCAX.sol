/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILUCAX {
    function resourceCollector() external view returns (address);
    function getOwner() external view returns (address);
}

contract FeeReceiverLUCAX {

    address public LUCAX = 0x324E8E649A6A3dF817F97CdDBED2b746b62553dD;
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint public oAmt  = 10;
    uint public xAmt  = 50;
    uint public rAmt  = 40;
    constructor(address _LUCAX,address _BUSD){
          LUCAX = _LUCAX;
 BUSD = IERC20(_BUSD);
    }

    modifier onlyOwner() {
        require(msg.sender == ILUCAX(LUCAX).getOwner(), 'Only Owner');
        _;
    }

    function setAmounts(
        uint _oAmt,
        uint _xAmt,
        uint _rAmt
    ) external onlyOwner {
        require(
            _oAmt + _xAmt + _rAmt == 100,
            'Invalid Amounts'
        );
        oAmt = _oAmt;
        xAmt = _xAmt;
        rAmt = _rAmt;
    }

    function trigger() external {

        uint bal = BUSD.balanceOf(address(this));
        if (bal > 0) {
            BUSD.transfer(
                ILUCAX(LUCAX).getOwner(),
                ( bal * oAmt ) / 100
            );

            BUSD.transfer(
                LUCAX,
                ( bal * xAmt ) / 100
            );

            BUSD.transfer(
                ILUCAX(LUCAX).resourceCollector(),
                BUSD.balanceOf(address(this))
            );
        }
    }

    function withdraw(IERC20 token) external onlyOwner {        
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}