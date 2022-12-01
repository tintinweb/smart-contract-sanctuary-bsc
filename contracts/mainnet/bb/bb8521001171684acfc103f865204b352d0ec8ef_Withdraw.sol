// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./interfaces/OperatorV2.sol";

import "./utils/TransferHelper.sol";

contract Withdraw is OperatorV2 {
    event WithdrawRequested(address owner, uint256 value, uint256 nonce);
    event Transfer(
        address from,
        address[] to,
        address[] tokens,
        uint256[] values,
        uint256[] nonce
    );

    uint256 public minFee = 5 * (10**9) * 50000;

    uint256 public wNonce = 0;
    uint256 public tNonce = 0;

    function setMinFee(uint256 minFee_) external onlyOwner {
        minFee = minFee_;
    }

    function takeValue(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }

    function withdrawRequest() external payable {
        require(msg.value >= minFee, "msg.val < minFee");
        emit WithdrawRequested(msg.sender, msg.value, ++wNonce);
    }

    function transfer(
        address[] memory tokens,
        address[] memory to,
        uint256[] memory values,
        uint256[] memory nonce
    ) external isOperator {
        uint256 toLen = to.length;
        uint256 tokensLen = tokens.length;

        require(toLen == nonce.length, "LM");
        require(tokensLen * toLen == values.length, "LM");

        uint256 wNonce_ = wNonce;
        uint256 tNonce_ = tNonce;
        uint256 maxNonce = 0;

        for (uint256 i = 0; i < toLen; ++i) {
            uint256 curNonce = nonce[i];
            require(curNonce > tNonce_ && curNonce <= wNonce_, "invalid nonce");
            if (maxNonce < curNonce) {
                maxNonce = curNonce;
            }
            for (uint256 j = 0; j < tokensLen; ++j) {
                uint256 val = values[i * tokensLen + j];
                if (val > 0) {
                    TransferHelper.safeTransferFrom(
                        tokens[j],
                        msg.sender,
                        to[i],
                        val
                    );
                }
            }
        }
        tNonce = maxNonce;
        emit Transfer(msg.sender, to, tokens, values, nonce);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./Ownable.sol";

abstract contract OperatorV2 is Ownable {
    mapping(address => bool) public operators;

    event OperatorUpdated(address operator, bool enabled);

    modifier isOperator() {
        require(operators[msg.sender], "not operator");
        _;
    }

    function setOperator(address operator, bool enabled) external onlyOwner {
        require(operator != address(0), "not owner");
        if (enabled) {
            operators[operator] = true;
        } else {
            delete operators[operator];
        }
        emit OperatorUpdated(operator, enabled);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}