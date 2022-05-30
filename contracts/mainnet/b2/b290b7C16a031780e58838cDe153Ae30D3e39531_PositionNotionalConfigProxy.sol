// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PositionNotionalConfigProxy is Initializable {
    bytes32 constant BTC_BUSD = "BTC_BUSD";
    bytes32 constant BNB_BUSD = "BNB_BUSD";

    function getMaxNotional(bytes32 key, uint16 leverage) external returns (uint256){
        if(key == BTC_BUSD) { //BTC_BUSD hash
            if(leverage == 1) {
                return 1_000_000_000_000;
            }else if(leverage == 2){
                return 6_000_000;
            }else if(leverage == 3){
                return 4_000_000;
            }else if(leverage == 4){
                return 2_000_000;
            }else if(leverage >= 5 && leverage <= 10){
                return 60_000;
            }else if(leverage > 10 && leverage <= 20){
                return 40_000;
            }else if(leverage > 20 && leverage <= 50){
                return 30_000;
            }else if(leverage > 50 && leverage <= 100){
                return 1_000_000;
            }else if(leverage > 100 && leverage <= 124){
                return 250_000;
            }
            return 50_000;
        } else if (key == BNB_BUSD) { //BNB_BUSD hash
            if(leverage == 1) {
                return 30_000_000;
            }else if(leverage == 2){
                return 5_000_000;
            }else if(leverage == 3){
                return 2_000_000;
            }else if(leverage == 4){
                return 1_000_000;
            }else if(leverage >= 5 && leverage <= 10){
                return 500_000;
            }else if(leverage > 10 && leverage <= 20){
                return 100_000;
            }else if(leverage > 20 && leverage <= 50){
                return 50_000;
            }else if(leverage > 50 && leverage <= 100){
                return 10_000;
            }
        }
        if(key == BNB_BUSD){ //BNB_BUSD hash
            if (leverage == 1) {
                return 30000000;
            } else if (leverage == 2) {
                return 5000000;
            } else if (leverage == 3) {
                return 2000000;
            } else if (leverage == 4) {
                return 1000000;
            } else if (leverage >= 5 && leverage <= 10) {
                return 500000;
            } else if (leverage > 10 && leverage <= 20) {
                return 100000;
            } else if (leverage > 20 && leverage <= 50) {
                return 50000;
            } else if (leverage > 50 && leverage <= 75) {
                return 10000;
            }
            return 10000;
        }
        return 50_000;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}