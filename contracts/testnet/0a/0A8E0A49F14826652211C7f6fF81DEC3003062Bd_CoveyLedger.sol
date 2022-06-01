/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

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
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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

contract CoveyLedger is Initializable {
    struct CoveyContent {
        address analyst;
        string content;
        uint256 created_at;
    }

    mapping(address => CoveyContent[]) analystContent;
    CoveyContent[] allContent;
    address owner;

    mapping(address => CoveyContent[]) backupContent;

    function initialize() public initializer {
        owner = msg.sender;
    }

    event ContentCreated(
        address indexed analyst,
        string content,
        uint256 indexed created_at
    );

    event AddressSwapped(
        address indexed oldAddress,
        address indexed newAddress
    );

    event LedgerBackup(address indexed analystAddress);
    event LedgerRestored(address indexed analystAddress);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function createContent(string memory content) public {
        CoveyContent memory c = CoveyContent({
            analyst: msg.sender,
            content: content,
            created_at: block.timestamp
        });
        analystContent[msg.sender].push(c);
        allContent.push(c);

        emit ContentCreated(msg.sender, content, block.timestamp);
    }

    function getAnalystContent(address _adr)
        public
        view
        returns (CoveyContent[] memory)
    {
        return analystContent[_adr];
    }

    function getAllContent() public view returns (CoveyContent[] memory) {
        return allContent;
    }

    function AddressSwitch(address oldAddress, address newAddress) public {
        require(msg.sender == oldAddress);
        require(
            analystContent[msg.sender].length > 0,
            'Cannot copy an empty ledger'
        );

        CoveyContent[] storage copyContent = analystContent[msg.sender];

        if (analystContent[newAddress].length > 0) {
            backupLedger(newAddress);
            CoveyContent[] memory existingLedger = analystContent[newAddress];
            delete analystContent[newAddress];
            for (uint256 i = 0; i < copyContent.length; i++) {
                if (copyContent[i].created_at < existingLedger[0].created_at) {
                    analystContent[newAddress].push(copyContent[i]);
                }
            }

            for (uint256 j = 0; j < existingLedger.length; j++) {
                analystContent[newAddress].push(existingLedger[j]);
            }
        } else {
            analystContent[newAddress] = copyContent;
        }

        emit AddressSwapped(oldAddress, newAddress);
    }

    function backupLedger(address analystAddress) private {
        require(analystContent[analystAddress].length > 0, 'Nothing to backup');

        CoveyContent[] storage backup = analystContent[analystAddress];

        backupContent[analystAddress] = backup;
        emit LedgerBackup(analystAddress);
    }

    function restoreLedger(address analystAddress) public {
        require(
            backupContent[analystAddress].length > 0,
            'No backup to restore'
        );
        CoveyContent[] storage backup = backupContent[analystAddress];
        analystContent[analystAddress] = backup;

        delete backupContent[analystAddress];

        emit LedgerRestored(analystAddress);
    }

    function getBackupContent(address _adr)
        public
        view
        returns (CoveyContent[] memory)
    {
        return backupContent[_adr];
    }
}