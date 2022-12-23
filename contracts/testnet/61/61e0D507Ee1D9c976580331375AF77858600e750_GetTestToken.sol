/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

contract GetTestToken {
    address private _owner;
    uint256 private transferAmount_ = 100000 * 10**8;

    mapping(address => uint256) private _lastTokenTransfer;

    event onTransfer(address indexed user, uint256 amount, uint256 timestamp);

    IBEP20 private mToken;

    constructor(address _mToken) {
        _owner = msg.sender;
        mToken = IBEP20(_mToken);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    /*=======================================
    =            CONSTANT FUNCTIONS         =
    =======================================*/
    function changeTransferToken(address _mToken) external onlyOwner {
        require(_mToken != address(0), "zero address");
        mToken = IBEP20(_mToken);
    }

    /*=======================================
    =            RECOVERY FUNCTIONS         =
    =======================================*/
    /// @dev BEP20 Token
    function recoverBEP20(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOwner {
        IBEP20(_token).transfer(_to, _amount);
    }

    /// @dev Native Token BNB
    function recoverBNB(address payable to) public onlyOwner {
        require(address(this).balance > 0, "zero native balance");
        (bool sent, ) = to.call{value: address(this).balance}("");
        require(sent, "BNB_TX_FAIL");
    }

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/
    function transfer() external {
        require(
            _lastTokenTransfer[msg.sender] + 60 seconds < block.timestamp,
            "only once every 60 sec"
        );

        _lastTokenTransfer[msg.sender] = block.timestamp;

        mToken.transfer(msg.sender, transferAmount_);
        emit onTransfer(msg.sender, transferAmount_, block.timestamp);
    }
}