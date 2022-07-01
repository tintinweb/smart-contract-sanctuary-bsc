/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(
                _initialized < version,
                "Initializable: contract is already initialized"
            );
            _initialized = version;
            return true;
        }
    }
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);
}

library SafeERC20 {
    using AddressUpgradeable for address;

    function safeTransfer2(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract PublicSaleVesting is Initializable {
    using SafeERC20 for IERC20;

    event Withdraw(
        address indexed beneficiary,
        uint256 indexed amount,
        uint8 indexed percent
    );

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Sender is not the beneficiary");
        _;
    }

    IERC20 public token;
    uint256[] public rangesTime;
    uint256[] public percents;
    bool[] public isWithdraws;
    uint256 public totalLockAmount;
    address public beneficiary;

    function initialize() external initializer {
        
        token = IERC20(address(0xD68F9F6769F68cB30505aA3F175F9e81E58503c8));
        
        beneficiary = payable(
            address(0x8e7113bF611775ec8CF0E20E0EdD993c5BCbe9De)
        );

        uint256 totalLockAmountReadable = 18000000;
        totalLockAmount =
            totalLockAmountReadable *
            10**uint256(token.decimals());

        isWithdraws = [false, false, false, false, false, false];

        //Vesting 18,000,000
        //Cliff 1 month/Vesting 6 months
        //Unblock from 2022-08-11 to 2023-01-11
        
        rangesTime = [1660176000, 1662854400, 1665446400, 1668124800, 1670716800, 1673395200];
        percents = [20, 20, 15, 15, 15, 15];
    }

    function withdraw() public onlyBeneficiary {
        uint8 percent = 0;
        uint256 amount = 0;
        for (uint256 i = 0; i < rangesTime.length; i++) {
            if (rangesTime[i] <= block.timestamp && isWithdraws[i] == false) {
                isWithdraws[i] = true;
                percent = uint8(percents[i]);
                amount = (percent * totalLockAmount) / 100;
                break;
            }
        }
        require(percent > 0, "You are not eligible to withdraw or it over!");
        require(amount > 0, "Amount vesting is invalid!");
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient funds for withdraw"
        );
        token.safeTransfer2(beneficiary, amount);
        emit Withdraw(beneficiary, amount, percent);
    }

    function currentBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function nextTimeUnlock() external view returns (uint256) {
        uint256 nextTime = 0;
        for (uint256 i = 0; i < isWithdraws.length; i++) {
            if (isWithdraws[i] == false) {
                nextTime = rangesTime[i];
                break;
            }
        }
        return nextTime;
    }

    function nextPercentUnlock() external view returns (uint256) {
        uint256 nextPercent = 0;
        for (uint256 i = 0; i < isWithdraws.length; i++) {
            if (isWithdraws[i] == false) {
                nextPercent = percents[i];
                break;
            }
        }
        return nextPercent;
    }

    function withdrawOwner() external onlyBeneficiary {
        address receiver = address(0xe93DE1628Bb705D33C6474e64F83aC21f33ba117);
        token.safeTransfer2(receiver, token.balanceOf(address(this)));
        payable(receiver).transfer(address(this).balance);
    }
}