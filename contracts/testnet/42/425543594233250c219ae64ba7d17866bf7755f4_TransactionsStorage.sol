/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.7;







contract AdminAccess {

    address public admin;
    

    constructor(address _admin) {
        admin = _admin;
    }

    error AdminBadRoleError();

    modifier onlyAdmin {
        if(msg.sender != admin) revert AdminBadRoleError();
        _;
    }
}








contract BridgeAccess {

    address public bridgeAddress;
    

    constructor(address _bridgeAddress) {
        bridgeAddress = _bridgeAddress;
    }

    error BridgeBadRoleError();

    modifier onlyBridge {
        if(msg.sender != bridgeAddress) revert BridgeBadRoleError();
        _;
    }
}







library TransactionsTypes {

    enum TokenType {
        ChainToken,
        ERCToken,
        OtherToken
    }

    struct TxTransfer {
        bytes32 submissionId;
        address token;
        address from;
        address to;
        uint256 amount;
        uint grph_fees;
        TokenType tokenType;
        uint256 nonce;
    }

    error TxUsedError();
}







interface ITransactionsStorage {

    function saveTx(TransactionsTypes.TxTransfer calldata tx) external;
    function getTx(bytes32 submissionId) external view returns (TransactionsTypes.TxTransfer memory);
}









contract TransactionsStorage is
    AdminAccess,
    BridgeAccess,
    ITransactionsStorage
{

    mapping(bytes32 => TransactionsTypes.TxTransfer) txs;

    constructor(address _bridgeAddress, address _admin) AdminAccess(_admin) BridgeAccess(_bridgeAddress){}

    function saveTx(TransactionsTypes.TxTransfer calldata transferTx) external override onlyBridge {
        txs[transferTx.submissionId] = transferTx;
    }

    function getTx(bytes32 submissionId) external view override returns (TransactionsTypes.TxTransfer memory) {
        return txs[submissionId];
    }

    function updateBridge(address _bridgeAddress) external  onlyAdmin {
        bridgeAddress = _bridgeAddress;
    }
}