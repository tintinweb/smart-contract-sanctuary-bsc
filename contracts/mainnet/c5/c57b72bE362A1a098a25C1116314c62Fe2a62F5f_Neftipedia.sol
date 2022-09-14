// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;
pragma experimental ABIEncoderV2;

import "./INEFTiLicense.sol";
import "./ERC1155MintBurnPackedBalance.sol";

/** 8662deae */
contract Neftipedia is ERC1155MintBurnPackedBalance {
    bytes32 public version = keccak256("1.10.55");
    // /** MultiTokens Info */
    string private _name;
    string private _symbol;

    /** 5fff73ee */
    function name() public override view virtual returns (string memory) { return _name; }
    /** 77bde41b */
    function symbol() public override view virtual returns (string memory) { return _symbol; }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ ERC165 ~~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/
    
    /**
    ** 3986ebc7
    ** @notice Query if a contract implements an interface
    ** @dev Parent contract inheriting multiple contracts with supportsInterface()
    **      need to implement an overriding supportsInterface() function specifying
    **      all inheriting contracts that have a supportsInterface() function.
    ** @param _interfaceID The interface identifier, as specified in ERC-165
    ** @return `true` if the contract implements `_interfaceID`
    **/
    function supportsInterface(bytes4 _interfaceID)
        public view virtual
        override( ERC1155PackedBalance )
        returns (bool)
    { return super.supportsInterface(_interfaceID); }

    /**
    ** 1288e0ce
    ** @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
    **/
    constructor (
        string memory name_,
        string memory symbol_,
        string memory baseMetadataURI_,
        address calcFeeExt_
    )
    {
        _name = name_;
        _symbol = symbol_;
        _setBaseMetadataURI(baseMetadataURI_);
        setCalcFeeExt(calcFeeExt_);
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ MINTING ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/
    
    /**
    ** 7de1cf6
    ** @dev Mint _value of tokens of a given id
    ** @param _to The address to mint tokens to.
    ** @param _id token id to mint
    ** @param _value The amount to be minted
    ** @param _data Data to be passed if receiver is contract
    **/
    function mint(address _to, uint256 _id, uint256 _value, bytes memory _data)
        public override payable
    {
        require(
            _to != address(0) &&
            _value > 0,
            "ENEFTiMP.01.INVALID_ARGUMENTS"
        );
        _mint(_to, _id, _value, _data);
    }
    
    /**
    ** 57392d88
    ** @dev Mint tokens for each ids in _ids
    ** @param _to The address to mint tokens to.
    ** @param _ids Array of ids to mint
    ** @param _values Array of amount of tokens to mint per id
    ** @param _data Data to be passed if receiver is contract
    **/
    function batchMint(address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data)
        public override payable
    { _batchMint(_to, _ids, _values, _data); }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ BURNING ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/
    
    /**
    ** ceb8d4bb
    ** @dev burn _value of tokens of a given token id
    ** @param _from The address to burn tokens from.
    ** @param _id token id to burn
    ** @param _value The amount to be burned
    **/
    function burn(address _from, uint256 _id, uint256 _value)
        public override
    { _burn(_from, _id, _value); }

    /**
    ** e20954ea
    ** @dev burn _value of tokens of a given token id
    ** @param _from The address to burn tokens from.
    ** @param _ids Array of token ids to burn
    ** @param _values Array of the amount to be burned
    **/
    function batchBurn(address _from, uint256[] memory _ids, uint256[] memory _values)
        public override
    { _batchBurn(_from, _ids, _values); }


    /*════════════════════════════oooooOooooo════════════════════════════╗
    ║█  (!) WARNING  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~█║
    ╚════════════════════════════════════════════════════════════════════╝
    ║  There are no handler in fallback function,                        ║
    ║  If there are any incoming value directly to Smart Contract, will  ║
    ║  considered as generous donation. And Thank you!                   ║
    ╚═══════════════════════════════════════════════════════════════════*/
    receive () external payable /* nonReentrant */ {}
    fallback () external payable /* nonReentrant */ {}
}

/**
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/*
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

/** d6147a8a */
interface INEFTiLicense {
    /** 921fe338 */
    function legalInfo() external view
        returns (string memory _title, string memory _license, string memory _version, string memory _url);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;

import "./ERC1155MetaPackedBalance.sol";
import "./IERC1155Metadata.sol";


/**
** @dev Multi-Fungible Tokens with minting and burning methods. These methods assume
**      a parent contract to be executed as they are `internal` functions.
**/
// abstract contract ERC1155MintBurnPackedBalance is ERC1155PackedBalance, IERC1155Metadata {
abstract contract ERC1155MintBurnPackedBalance is ERC1155MetaPackedBalance, IERC1155Metadata {
    // URI's default URI prefix
    string internal baseMetadataURI;


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ METADATA ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice A distinct Uniform Resource Identifier (URI) for a given token.
    ** @dev URIs are assumed to be deterministically generated based on token ID, defined in RFC 3986.
    ** @return URI string
    **/
    function uri(uint256 _id)
        public view override
        returns (string memory)
    {
        // return string(abi.encodePacked(baseMetadataURI, _uint2str(_id), ".json"));
        return string(abi.encodePacked(baseMetadataURI, _getURI(_id), "/metadata.json"));
    }

    /**
    ** @dev Update Base MetadataURI of token id. URIs are defined in RFC 3986.
    **      URIs are assumed to be deterministically generated based on token ID
    ** @param _newBaseMetadataURI URI
    **/
    function setBaseMetadataURI(string memory _newBaseMetadataURI)
        public onlyOwner
    { _setBaseMetadataURI(_newBaseMetadataURI); }

    /**
    ** @notice Will emit default URI log event for corresponding token _id
    ** @param _tokenIDs Array of IDs of tokens to log default URI
    **/
    function logURIs(uint256[] memory _tokenIDs)
        public onlyOwner
    { _logURIs(_tokenIDs); }
    function _logURIs(uint256[] memory _tokenIDs)
        internal
    {
        string memory tokenURI;
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
        tokenURI = string(abi.encodePacked(baseMetadataURI, _getURI(_tokenIDs[i]), ".json"));
        emit URI(tokenURI, _tokenIDs[i]);
        }
    }

    /**
    ** @notice Will update the base URL of token's URI
    ** @param _newBaseMetadataURI New base URL of token's URI
    **/
    function _setBaseMetadataURI(string memory _newBaseMetadataURI)
        internal
    { baseMetadataURI = _newBaseMetadataURI; }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ MINTING ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Mint amount of tokens of a given id
    ** @param _to      The address to mint tokens to
    ** @param _id      Token id to mint
    ** @param _amount  The amount to be minted
    ** @param _data    Data to pass if receiver is contract
    **/
    function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
        internal
    {
        _id = (_id == 0) ? _requestId() : _id;
        //-- transfer mint Fee
        (uint8 _feeType, ) = getDefaultFeeType();
        (uint256[3] memory mintFee, , ) = INEFTiMTFeeCalcExt(NEFTiMTFeeCalcExt).getMintFee(_amount);
        _payFee(mintFee[0], mintFee[1], mintFee[2], _feeType);

        if (_checkMintType(_id) == MintType.Add) {
            _mintAddNew(_to, _id, _amount, _data);
            _setMinters(_to, _id);
            _setHoldedTokens(_to, _id);
        }
        else { _mintAddNew(_to, _id, _amount, _data); }
    }

    /**
    ** @notice Mint to add more supply (internal use)
    ** @param _to      The address to mint tokens to
    ** @param _id      Token id to mint
    ** @param _amount  The amount to be minted
    ** @param _data    Data to pass if receiver is contract
    **/
    function _mintAddNew(address _to, uint256 _id, uint256 _amount, bytes memory _data)
        internal
    {
        // Add _amount
        _updateIDBalance(_to,   _id, _amount, Operations.Add);
        // Add resource
        _updateIDResources(_id, _data);
        _setSupplies(_id, _amount, true);

        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);
        // Calling onReceive method if recipient is contract
        _callonERC1155Received(address(0x0), _to, _id, _amount, gasleft(), _data);
    }

    /**
    ** @notice Mint tokens for each (_ids[i], _amounts[i]) pair
    ** @param _to       The address to mint tokens to
    ** @param _ids      Array of ids to mint
    ** @param _amounts  Array of amount of tokens to mint per id
    ** @param _data    Data to pass if receiver is contract
    **/
    function _batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
        internal
    {
        require(_ids.length == _amounts.length, "ENEFTi1155MBPB.01.ARRAYS_LENGTH_MISMATCH");

        if (_ids.length > 0) {
            _ids[0] = (_ids[0] == 0) ? _requestId() : _ids[0];
            address minter = minterOf(_ids[0]);
            (uint8 _feeType, ) = getDefaultFeeType();
            // Load first bin and index where the token ID balance exists
            (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);
            // Balance for current bin in memory (initialized with first transfer)
            uint256 balTo = _viewUpdateBinValue(balances[_to][bin], index, _amounts[0], Operations.Add);

            //-- transfer mint Fee all at once
            (uint256[3] memory mintFee, , ) = INEFTiMTFeeCalcExt(NEFTiMTFeeCalcExt).getBatchMintFee(_amounts);
            _payFee(mintFee[0], mintFee[1], mintFee[2], _feeType);
            // Last bin updated
            uint256 lastBin = bin;
            uint256 i;
            for (i = 1; i < _ids.length; i++) {
                _ids[i] = (_ids[i] == 0) ? _requestId() : _ids[i];
                minter = minterOf(_ids[i]);
                (bin, index) = getIDBinIndex(_ids[i]);

                // If new bin
                if (bin != lastBin) {
                    if (_checkMintType(_ids[i-1]) == MintType.Add) {
                        // Update storage balance of previous bin
                        balances[_to][lastBin] = balTo;
                        balTo = balances[_to][bin];
                        // Update related storages
                        _setMinters(_to, _ids[i-1]);
                        _setSupplies(_ids[i-1], balTo, true);
                        _setHoldedTokens(_to, _ids[i-1]);
                        _updateIDResources(_ids[i-1], _data);
                    }
                    else {
                        // Update balance storage
                        balances[_to][lastBin] = balTo;
                        balTo = balances[_to][bin];
                        // Update related storages
                        _updateIDResources(_ids[i-1], _data);
                    }
                    // Bin will be the most recent bin
                    lastBin = bin;
                }
                // Update memory balance
                balTo = _viewUpdateBinValue(balTo, index, _amounts[i], Operations.Add);
            }

            if (_checkMintType(_ids[i-1]) == MintType.Add) {
                // Update storage of the last bin visited
                balances[_to][bin] = balTo;
                // Update related storages
                _setMinters(_to, _ids[i-1]);
                _setSupplies(_ids[i-1], balTo, true);
                _setHoldedTokens(_to, _ids[i-1]);
                _updateIDResources(_ids[i-1], _data);
            }
            else {
                // Update storage balance of the last bin visited
                balances[_to][bin] = balTo;
                // Update related storages
                _setSupplies(_ids[i-1], balTo, true);
                _updateIDResources(_ids[i-1], _data);
            }
        }
        // Empty Ids, nothing to proceed
        else { return; }

        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);
        // Calling onReceive method if recipient is contract
        _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, gasleft(), _data);
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ BURNING ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Burn amount of tokens of a given token id
    ** @param _from    The address to burn tokens from
    ** @param _id      Token id to burn
    ** @param _amount  The amount to be burned
    **/
    function _burn(address _from, uint256 _id, uint256 _amount)
        internal
    {
        // Substract _amount
        _updateIDBalance(_from, _id, _amount, Operations.Sub);
        _setSupplies(_id, _amount, false);
        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    /**
    ** @notice Burn tokens of given token id for each (_ids[i], _amounts[i]) pair
    ** @dev This batchBurn method does not implement the most efficient way of updating
    **      balances to reduce the potential bug surface as this function is expected to
    **      be less common than transfers. EIP-2200 makes this method significantly
    **      more efficient already for packed balances.
    ** @param _from     The address to burn tokens from
    ** @param _ids      Array of token ids to burn
    ** @param _amounts  Array of the amount to be burned
    **/
    function _batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts)
        internal
    {
        // Number of burning to execute
        uint256 nBurn = _ids.length;
        require(nBurn == _amounts.length, "ENEFTi1155MBPB.02.ARRAYS_LENGTH_MISMATCH");

        // Executing all burning
        for (uint256 i = 0; i < nBurn; i++) {
            // Update storage balance
            _updateIDBalance(_from,   _ids[i], _amounts[i], Operations.Sub); // Add amount to recipient
            // Update related storages
            _setSupplies(_ids[i], _amounts[i], false);
        }

        emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;
pragma experimental ABIEncoderV2;


import "./ERC1155PackedBalance.sol";
import "./IERC20.sol";
import "./IERC1155.sol";
import "./LibBytes.sol";
import "./SignatureValidator.sol";


/**
** @dev ERC-1155 with native MetaTransaction methods.
**      These additional functions allow users to presign function calls and
**      allow third parties to execute these on their behalf.
**/
abstract contract ERC1155MetaPackedBalance is ERC1155PackedBalance, SignatureValidator {
    using LibBytes for bytes;


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** Gas Receipt
    **   feeTokenData : (bool, address, ?unit256)
    **     1st element should be the address of the token
    **     2nd argument (if ERC-1155) should be the ID of the token
    **     Last element should be a 0x0 if ERC-20 and 0x1 for ERC-1155
    **/
    struct GasReceipt {
        uint256 gasFee;           // Fixed cost for the tx
        uint256 gasLimitCallback; // Maximum amount of gas the callback in transfer functions can use
        address feeRecipient;     // Address to send payment to
        bytes   feeTokenData;       // Data for token to pay for gas
    }

    /** Which token standard is used to pay gas fee */
    enum FeeTokenType {
        ERC1155,    // 0x00, ERC-1155 token - DEFAULT
        ERC20,      // 0x01, ERC-20 token
        NTypes      // 0x02, number of signature types. Always leave at end.
    }

    // /** Signature nonce per address */
    mapping (address => uint256) internal nonces;

    // keccak256( "metaSafeTransferFrom(address,address,uint256,uint256,bool,bytes)" );
    bytes32 internal constant META_TX_TYPEHASH = 0xce0b514b3931bdbe4d5d44e4f035afe7113767b7db71949271f6a62d9c60f558;
    // keccak256( "metaSafeBatchTransferFrom(address,address,uint256[],uint256[],bool,bytes)" );
    bytes32 internal constant META_BATCH_TX_TYPEHASH = 0xa3d4926e8cf8fe8e020cd29f514c256bc2eec62aa2337e415f1a33a4828af5a0;
    // keccak256( "metaSetApprovalForAll(address,address,bool,bool,bytes)" );
    bytes32 internal constant META_APPROVAL_TYPEHASH = 0xf5d4c820494c8595de274c7ff619bead38aac4fbc3d143b5bf956aa4b84fa524;
    // keccak256( "NEFTiAssetOwnership(address signer,uint256 tokenId)" );
    bytes32 public constant META_NEFTi_OWNERSHIP_TYPEHASH = 0x39ec3a9ba4d169b5881dc884412106cdbee7f26e164982c6e7299d408e770c78;

    event NonceChange(address indexed signer, uint256 newNonce);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~ META-TRANSFER ~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Allows anyone with a valid signature to transfer _amount amount of a token _id on the behalf of _from
    ** @param _from     Source address
    ** @param _to       Target address
    ** @param _id       ID of the token type
    ** @param _amount   Transfered amount
    ** @param _isGasFee Whether gas is reimbursed to executor or not
    ** @param _data     Encodes a meta transfer indicator, signature, gas payment receipt and extra transfer data
    **   _data should be encoded as (
    **   (bytes32 r, bytes32 s, uint8 v, uint256 nonce, SignatureType sigType),
    **   (GasReceipt g, ?bytes transferData)
    ** )
    ** (i) i.e.: high level encoding should be (bytes, bytes), where the later bytes array is a nested bytes array
    **/
    function metaSafeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bool    _isGasFee,
        bytes   memory _data
    )
        public
    {
        require(_to != address(0), "ERC1155MetaPackedBalance#metaSafeTransferFrom: INVALID_RECIPIENT");

        // Initializing
        bytes memory transferData;
        GasReceipt memory gasReceipt;

        // Verify signature and extract the signed data
        bytes memory signedData = _signatureValidation(
            _from,
            _data,
            abi.encode(
                META_TX_TYPEHASH,
                _from, // Address as uint256
                _to,   // Address as uint256
                _id,
                _amount,
                _isGasFee ? uint256(1) : uint256(0)  // Boolean as uint256
            )
        );
        // Transfer asset
        _safeTransferFrom(_from, _to, _id, _amount);
        // If Gas is being reimbursed
        if (_isGasFee) {
            (gasReceipt, transferData) = abi.decode(signedData, (GasReceipt, bytes));
            // We need to somewhat protect relayers against gas griefing attacks in recipient contract.
            // Hence we only pass the gasLimit to the recipient such that the relayer knows the griefing limit.
            // Nothing can prevent the receiver to revert the transaction as close to the gasLimit as possible,
            // but the relayer can now only accept meta-transaction gasLimit within a certain range.
            _callonERC1155Received(_from, _to, _id, _amount, gasReceipt.gasLimitCallback, transferData);
            // Transfer gas cost
            _transferGasFee(_from, gasReceipt);
        } else { _callonERC1155Received(_from, _to, _id, _amount, gasleft(), signedData); }
    }

    /**
    ** @notice Allows anyone with a valid signature to transfer multiple types of tokens on the behalf of _from
    ** @param _from     Source addresses
    ** @param _to       Target addresses
    ** @param _ids      IDs of each token type
    ** @param _amounts  Transfer amounts per token type
    ** @param _isGasFee Whether gas is reimbursed to executor or not
    ** @param _data     Encodes a meta transfer indicator, signature, gas payment receipt and extra transfer data
    **   _data should be encoded as (
    **   (bytes32 r, bytes32 s, uint8 v, uint256 nonce, SignatureType sigType),
    **   (GasReceipt g, ?bytes transferData)
    ** )
    ** (i) i.e.: high level encoding should be (bytes, bytes), where the later bytes array is a nested bytes array
    **/
    function metaSafeBatchTransferFrom(
        address   _from,
        address   _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bool      _isGasFee,
        bytes     memory _data
    )
        public
    {
        require(_to != address(0), "ENEFTi1155MPB__metaSafeBatchTransferFrom__INVALID_RECIPIENT");

        // Initializing
        bytes memory transferData;
        GasReceipt memory gasReceipt;

        // Verify signature and extract the signed data
        bytes memory signedData = _signatureValidation(
            _from,
            _data,
            abi.encode(
                META_BATCH_TX_TYPEHASH,
                _from, // Address as uint256
                _to,   // Address as uint256
                keccak256(abi.encodePacked(_ids)),
                keccak256(abi.encodePacked(_amounts)),
                _isGasFee ? uint256(1) : uint256(0)  // Boolean as uint256
            )
        );
        // Transfer assets
        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        // If gas fee being reimbursed
        if (_isGasFee) {
            (gasReceipt, transferData) = abi.decode(signedData, (GasReceipt, bytes));
            // We need to somewhat protect relayers against gas griefing attacks in recipient contract.
            // Hence we only pass the gasLimit to the recipient such that the relayer knows the griefing
            // limit. Nothing can prevent the receiver to revert the transaction as close to the gasLimit as
            // possible, but the relayer can now only accept meta-transaction gasLimit within a certain range.
            _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasReceipt.gasLimitCallback, transferData);
            // Handle gas reimbursement
            _transferGasFee(_from, gasReceipt);
        } else { _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), signedData); }
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ OPERATOR ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Approve the passed address to spend on behalf of _from if valid signature is provided
    ** @param _owner     Address that wants to set operator status  _spender
    ** @param _operator  Address to add to the set of authorized operators
    ** @param _approved  True if the operator is approved, false to revoke approval
    ** @param _isGasFee  Whether gas will be reimbursed or not, with vlid signature
    ** @param _data      Encodes signature and gas payment receipt
    **   _data should be encoded as (
    **     (bytes32 r, bytes32 s, uint8 v, uint256 nonce, SignatureType sigType),
    **     (GasReceipt g)
    **   )
    ** (i) i.e.: high level encoding should be (bytes, bytes), where the latter bytes array is a nested bytes array
    **/
    function metaSetApprovalForAll(
        address _owner,
        address _operator,
        bool    _approved,
        bool    _isGasFee,
        bytes   memory _data
    )
        public
    {
        // Verify signature and extract the signed data
        bytes memory signedData = _signatureValidation(
            _owner,
            _data,
            abi.encode(
                META_APPROVAL_TYPEHASH,
                _owner,                              // Address as uint256
                _operator,                           // Address as uint256
                _approved ? uint256(1) : uint256(0), // Boolean as uint256
                _isGasFee ? uint256(1) : uint256(0)  // Boolean as uint256
            )
        );
        // Update operator status
        operators[_owner][_operator] = _approved;
        // Emit event
        emit ApprovalForAll(_owner, _operator, _approved);
        // Handle gas reimbursement
        if (_isGasFee) {
            GasReceipt memory gasReceipt = abi.decode(signedData, (GasReceipt));
            _transferGasFee(_owner, gasReceipt);
        }
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~ SIGNATURE VALIDATION ~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Verifies signatures for this contract
    ** @param _signer     Address of signer
    ** @param _sigData    Encodes signature, gas payment receipt and transfer data (if any)
    ** @param _encMembers Encoded EIP-712 type members (except nonce and _data), all need to be 32 bytes size
    ** @dev _data should be encoded as (
    **   (bytes32 r, bytes32 s, uint8 v, uint256 nonce, SignatureType sigType),
    **   (GasReceipt g, ?bytes transferData)
    ** )
    ** (i) i.e.: high level encoding should be (bytes, bytes), where the latter bytes array is a nested bytes array
    ** @dev A valid nonce is a nonce that is within 100 value from the current nonce
    **/
    function _signatureValidation(address _signer, bytes memory _sigData, bytes memory _encMembers)
        internal
        returns (bytes memory signedData)
    {
        bytes memory sig;
        // Get signature and data to sign
        (sig, signedData) = abi.decode(_sigData, (bytes, bytes));

        // Get current nonce and nonce used for signature
        uint256 currentNonce = nonces[_signer];        // Lowest valid nonce for signer
        uint256 nonce = uint256(sig.readBytes32(65));  // Nonce passed in the signature object
        // Verify if nonce is valid
        require((nonce >= currentNonce) && (nonce < (currentNonce + 100)), "ENEFTi1155MPB__|_signatureValidation__INVALID_NONCE" );

        // Take hash of bytes arrays
        bytes32 hash = hashEIP712Message(keccak256(abi.encodePacked(_encMembers, nonce, keccak256(signedData))));
        // Complete data to pass to signer verifier
        bytes memory fullData = abi.encodePacked(_encMembers, nonce, signedData);
        //Update signature nonce
        nonces[_signer] = nonce + 1;
        emit NonceChange(_signer, nonce + 1);
        // Verify if _from is the signer
        (bool isValid, ) = isValidSignature(_signer, hash, fullData, sig);
        require(isValid, "ENEFTi1155MPB__|_signatureValidation__INVALID_SIGNATURE");
        return signedData;
    }

    /**
    ** @notice Returns the current nonce associated with a given address
    ** @param _signer Address to query signature nonce for
    **/
    function getNonce(address _signer)
        public view
        returns (uint256 nonce)
    { return nonces[_signer]; }

    /**
    ** @dev Meta to Verify Resource Asset Ownership
    ** @param _signer  An address which request asset resource to verify
    ** @param _hash    Hash of the signed data
    ** @param _r       Signed R
    ** @param _s       Signed S
    ** @param _v       Signed V
    ** keccak256(abi.encodePacked(
    **    EIP191_HEADER,
    **    keccak256(abi.encode( DOMAIN_SEPARATOR_TYPEHASH, address(this) )),
    **    keccak256(abi.encode( META_NEFTi_OWNERSHIP_TYPEHASH, _signer, _tokenId ))
    ** ));
    **/
    function verifyOwnership(
        address _signer,
        bytes32 _hash,
        bytes32 _r,
        bytes32 _s,
        uint8   _v
    )
        public view
        returns (bool success, address signer)
    {
        uint8 _st = 0x01;
        bytes memory sig = abi.encodePacked(
            _r, _s, _v,
            (nonces[_signer] > 0 ? nonces[_signer] : 1),
            _st
        );
        bytes32 hashMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
        (bool ok, ) = isValidSignature(_signer, hashMessage, "", sig);
        return ( ok, ok ? _signer : address(0) );
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~ GAS REIMBURSEMENT ~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Will reimburse tx.origin or fee recipient for the gas spent execution a transaction
    **         Can reimbuse in any ERC-20 or ERC-1155 token
    ** @param _from  Address from which the payment will be made from
    ** @param _g     GasReceipt object that contains gas reimbursement information
    **/
    function _transferGasFee(address _from, GasReceipt memory _g)
        internal
    {
        // Pop last byte to get token fee type
        uint8 feeTokenTypeRaw = uint8(_g.feeTokenData.popLastByte());
        // Ensure valid fee token type
        require(feeTokenTypeRaw < uint8(FeeTokenType.NTypes), "ENEFTi1155MPB__|_transferGasFee__UNSUPPORTED_TOKEN");

        // Convert to FeeTokenType corresponding value
        FeeTokenType feeTokenType = FeeTokenType(feeTokenTypeRaw);

        // Declarations
        address tokenAddress;
        address feeRecipient;
        uint256 tokenID;
        uint256 fee = _g.gasFee;
        // If receiver is 0x0, then anyone can claim, otherwise, refund addressee provided
        feeRecipient = _g.feeRecipient == address(0) ? msg.sender : _g.feeRecipient;
        // Fee token is ERC1155
        if (feeTokenType == FeeTokenType.ERC1155) {
            (tokenAddress, tokenID) = abi.decode(_g.feeTokenData, (address, uint256));
            // Fee is paid from this ERC1155 contract
            if (tokenAddress == address(this)) {
                _safeTransferFrom(_from, feeRecipient, tokenID, fee);
                // No need to protect against griefing since recipient (if contract) is most likely owned by the relayer
                _callonERC1155Received(_from, feeRecipient, tokenID, gasleft(), fee, "");
            }
            // Fee is paid from another ERC-1155 contract
            else { IERC1155(tokenAddress).safeTransferFrom(_from, feeRecipient, tokenID, fee, ""); }

        }
        // Fee token is ERC20
        else {
            tokenAddress = abi.decode(_g.feeTokenData, (address));
            require(IERC20(tokenAddress).transferFrom(_from, feeRecipient, fee), "ENEFTi1155MPB__|_transferGasFee__ERC20_TRANSFER_FAILED");
        }
    }
}

// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.7.4 <=0.8.9;


interface IERC1155Metadata {

  event URI(string _uri, uint256 indexed _id);

  /****************************************|
  |                Functions               |
  |_______________________________________*/

  /**
   * @notice A distinct Uniform Resource Identifier (URI) for a given token.
   * @dev URIs are defined in RFC 3986.
   *      URIs are assumed to be deterministically generated based on token ID
   *      Token IDs are assumed to be represented in their hex format in URIs
   * @return URI string
   */
  function uri(uint256 _id) external view returns (string memory);
}

// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.7.4 <=0.8.9;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./IERC1155TokenReceiver.sol";
import "./IERC1155.sol";
import "./INEFTiMultiTokens.sol";
import "./Address.sol";
import "./ERC165.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./INEFTiMTFeeCalcExt.sol";


/**
 * @dev Implementation of Multi-Token Standard contract. This implementation of the ERC-1155 standard
 *      utilizes the fact that balances of different token ids can be concatenated within individual
 *      uint256 storage slots. This allows the contract to batch transfer tokens more efficiently at
 *      the cost of limiting the maximum token balance each address can hold. This limit is
 *      2^IDS_BITS_SIZE, which can be adjusted below. In practice, using IDS_BITS_SIZE smaller than 16
 *      did not lead to major efficiency gains.
 */
abstract contract ERC1155PackedBalance is INEFTiMultiTokens, ERC165, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    // onReceive function signatures
    bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    // Constants regarding bin sizes for balance packing
    // IDS_BITS_SIZE **MUST** be a power of 2 (e.g. 2, 4, 8, 16, 32, 64, 128)
    uint256 internal constant IDS_BITS_SIZE   = 32;                  // Max balance amount in bits per token ID
    uint256 internal constant IDS_PER_UINT256 = 256 / IDS_BITS_SIZE; // Number of ids per uint256

    // Operations for _updateIDBalance
    enum Operations { Add, Sub }
    // MintType for _checkMintType
    enum MintType { Add, Update }

    address internal NEFTiMTFeeCalcExt;

    /**
    ** @dev MultiTokens balance storage layout
    ** @params address  User Wallet Address
    ** @params uint256  Token ID
    ** @return uint256  Balance
    **/
    mapping (address => mapping(uint256 => uint256)) internal balances;
    /**
    ** @dev MultiTokens supplies each token id
    ** @params uint256  Token ID
    ** @return uint256  Supply
    **/
    mapping (uint256 => uint256) internal supplies;
    /**
    ** @dev MultiTokens minters address each token id
    ** @params uint256  Token ID
    ** @return Token id supply
    **/
    mapping (uint256 => address) internal minters;
    /**
    ** @dev MultiTokens resources data each token id
    ** @params uint256  Token ID
    ** @return Resource Data
    **/
    mapping (uint256 => bytes) internal resources;
    /**
    ** @dev MultiTokens holders map
    ** @params address    User Wallet Address
    ** @return uint256[]  List of Token ID
    **/
    mapping (address => uint256[]) internal holders;
    /**
    ** @dev Signature nonce of ReqMinter per address
    ** @params address  User Wallet Address
    ** @return uint256  Nonce
    **/
    mapping (address => uint256) internal reqIdNonces;
    /**
    ** @dev Operator to mint tokens
    ** @params address  Item owner (authorizer)
    ** @params address  Destination operator to authorize
    ** @return bool - Allowance state
    **/
    mapping (address => mapping(address => bool)) internal operators;

    event RequestId(address indexed asAddress, uint256 indexed asUInt);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ UTILITIES ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @dev Generate a unique ID (public use)
    ** Sample: 0xf4a8f74879182ff2a07468508bec89e1e7464027		          
    **/  
    function requestId()
        public override
    {
        uint256 _id = _requestId();
        emit RequestId(address(uint160(_id)), _id);
    }

    /**
    ** @dev Generate a unique ID (internal use)
    ** @return _id Unique Identifier
    **/ 
    function _requestId()
        internal
        returns (uint256 _id)
    {
        uint256 nonce = reqIdNonces[msg.sender] + 1;
        bytes32 b = keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, nonce, block.timestamp));
        bytes20 b20 = bytes20(b);
        uint256 addr = 0;
        for (uint256 index = b20.length-1; index > 0; index--) {
            addr += uint8(b20[index]) * ( 18 ** ((b20.length - index) * 2));
        }
        
        address checkId = minters[addr];
        reqIdNonces[msg.sender]++;

        if (checkId != address(0)) { requestId(); }
        else { return addr; }
    }

    /**
    ** @dev Owned items of the given address
    ** @param _holder The address of the owner
    ** @return _ids The list of owned item ids
    **/
    function itemsOf(address _holder)
        public override view
        returns (uint256[] memory)
    {
        require(_holder != address(0), "ENEFTi1155PB.01.INVALID_GIVEN_ADDRESS");
        return holders[_holder];
    }

    /**
    ** @dev Set item to new owner
    ** @param _holder Owner address
    ** @param _id Item id
    */
    function _setHoldedTokens(address _holder, uint256 _id)
        internal
    {
        if (holders[_holder].length > 0) {
            for (uint256 i=0; i < holders[_holder].length; i++) {
                if (holders[_holder][i] == _id) { return; }
            }
            holders[_holder].push(_id);
        }
        else { holders[_holder].push(_id); }
    }

    /**
    ** @dev Get list of holded items by owner address
    ** @param _holder Owner address
    ** @return _ids List of holded items
    **/
    function _getHoldedTokens(address _holder)
        internal view
        returns (uint256[] memory)
    {
        if (holders[_holder].length == 0) { return holders[_holder]; }
        
        uint256 skip;
        for (uint256 i=0; i < holders[_holder].length; i++) {
            if (_balanceOf( _holder, holders[_holder][i] ) == 0) { skip++; }
        }
        uint256[] memory ids = new uint[]( holders[_holder].length - skip );
        uint256 idx;
        for (uint256 j=0; j < holders[_holder].length; j++) {
            if (_balanceOf( _holder, holders[_holder][j] ) > 0) {
                ids[idx] = holders[_holder][j];
                idx++;
            }
        }
        return ids;
    }

    /**
    ** @dev Update CalcFee extension
    ** @param _newCalcFeeExt CalcFee extension
    **/
    function setCalcFeeExt(address _newCalcFeeExt)
        public onlyOwner
    {
        require(_newCalcFeeExt != address(0), "ENEFTi1155MBPB.02.UNKNOWN_EXTENSION");
        NEFTiMTFeeCalcExt = _newCalcFeeExt;
    }

    /**
    ** @dev Get Default Fee type
    ** @return (
    **    feeType - Fee type
    **    feeTypeAsString - Fee type as string
    ** )
    **/
    function getDefaultFeeType()
        public view
        returns(uint8 feeType, string memory feeTypeAsString)
    { return INEFTiMTFeeCalcExt(NEFTiMTFeeCalcExt).getDefaultPaymentType(); }

    /**
    ** @dev Get Mint Fee info
    ** @param amount Amount of tokens to mint
    ** @return (
    **    mintFee - Fee format
    **    multitokenOnEach - multiplier amounts
    **    feeAs - Fee type as string
    ** )
    **/
    function getMintFee(uint256 amount)
        public override view
        returns( uint256[3] memory mintFee, uint256 multitokenOnEach, string memory feeAs )
    { return INEFTiMTFeeCalcExt(NEFTiMTFeeCalcExt).getMintFee(amount); }

    /**
    ** @dev Get Batch Mint Fee info
    ** @param _amounts List of amounts of tokens to mint
    ** @return (
    **    mintFee - Fee format
    **    multitokenOnEach - multiplier amounts
    **    feeAs - Fee type as string
    ** )
    **/
    function getBatchMintFee(uint256[] memory _amounts)
        public override view
        returns( uint256[3] memory mintFee, uint256 multitokenOnEach, string memory feeAs )
    { return INEFTiMTFeeCalcExt(NEFTiMTFeeCalcExt).getBatchMintFee(_amounts); }
    
    /**
    ** @dev Set item supply
    ** @param _id Item id
    ** @param _amount Supply amount
    ** @param _addOperation True if Add operation, else Substract operation
    **/
    function _setSupplies(uint256 _id, uint256 _amount, bool _addOperation)
        internal
    { supplies[_id] = (_addOperation ? supplies[_id].add(_amount) : supplies[_id].sub(_amount)); }

    /**
    ** @dev Get item total supply
    ** @param _id Item id
    ** @return Total supply amount
    **/
    function totalSupply(uint256 _id)
        public override view
        returns( uint256 )
    { return supplies[_id]; }

    /**
    ** @dev Set authorize minter of minted item
    ** @param _holder Minter address (creator)
    ** @param _id Item id
    **/
    function _setMinters(address _holder, uint256 _id)
        internal
    { minters[_id] = _holder; }

    /**
    ** @dev Get authorize minter of minted item
    ** @param _id Item id
    ** @return Minter address
    **/
    function minterOf(uint256 _id)
        public override view
        returns (address)
    {
        require(_id > 0, "ENEFTi1155PB.03.INVALID_GIVEN_ID");
        return minters[_id];
    }

    /**
    ** @dev Check things before do mint new item (internal use)
    ** @param _id Token Id
    ** @return MintType operation Add or Update
    **/
    function _checkMintType(uint256 _id)
        internal view
        returns (MintType)
    {
        address minter = minterOf(_id);

        // mint token for new token id
        if (minter == address(0) || minter == address(0x0)) {
            // OnlyOwner allowed for specific length of Ids
            if (_id <= 99999999999999999999) { require(msg.sender == owner(), "ENEFTi1155MBPB.04.FORBIDDEN_ID"); }
            return (MintType.Add);
        }
        // mint token for existing id, to add amount
        else {
            require((msg.sender == minter) || (msg.sender == owner()), "ENEFTi1155MBPB.05.UNATHORIZED_MINTER");
            require(totalSupply(_id) > 1, "ENEFTi1155MBPB.06.PROHIBITED_ON_NFT_TYPE");
            return (MintType.Update);
        }
    }

    /**
    ** @dev Execution to pay fee (internal use)
    ** @param bnbFee If defined as coin
    ** @param b20Fee If defined as erc-20 token
    ** @param nftFee If defined as NEFTi token
    **/
    function _payFee(uint256 bnbFee, uint256 b20Fee, uint256 nftFee, uint8 fPayMode)
        internal
    {
        IERC20 b20Token = IERC20(0x8e87DB40C5E9335a8FE19333Ffc19AD95C665f60); // DOO
        IERC20 nftToken = IERC20(0xFaAb744dB9def8e13194600Ed02bC5D5BEd3B85C); // NFT

        // MODE_BNB_NFT
        if (fPayMode == 0) {
            require(msg.value >= bnbFee, "ENEFTi1155MBPB.07.NOT_ENOUGH_COINS");
            require(nftToken.allowance(msg.sender, address(this)) >= nftFee, "ENEFTi1155MBPB.08.NFT_ALLOWANCE");
            transferCoin(payable(owner()), bnbFee);
            nftToken.safeTransferFrom(msg.sender, owner(), nftFee);
        }
        // MODE_BNB
        else if (fPayMode == 1) {
            require(msg.value >= bnbFee, "ENEFTi1155MBPB.09.BNB.NOT_ENOUGH_COINS");
            transferCoin(payable(owner()), bnbFee);
        }
        // MODE_B20_NFT
        else if (fPayMode == 2) {
            require(b20Token.allowance(msg.sender, address(this)) >= b20Fee, "ENEFTi1155MBPB.10.B20_ALLOWANCE");
            require(nftToken.allowance(msg.sender, address(this)) >= nftFee, "ENEFTi1155MBPB.11.NFT_ALLOWANCE");
            b20Token.safeTransferFrom(msg.sender, owner(), b20Fee);
            nftToken.safeTransferFrom(msg.sender, owner(), nftFee);
        }
        // MODE_B20
        else if (fPayMode == 3) {
            require(b20Token.allowance(msg.sender, address(this)) >= b20Fee, "ENEFTi1155MBPB.12.B20_ALLOWANCE");
            b20Token.safeTransferFrom(msg.sender, owner(), nftFee);
        }
        // MODE_NFT
        else {
            require(nftToken.allowance(msg.sender, address(this)) >= nftFee, "ENEFTi1155MBPB.13.NFT_ALLOWANCE");
            nftToken.safeTransferFrom(msg.sender, owner(), nftFee);
        }
    }

    /**
    ** @dev Execution transfer coin (internal use)
    ** @param recipient Receiver address
    ** @param amount    Amount for transfer
    **/
    function transferCoin(address recipient, uint256 amount)
        private
    { (bool res,) = recipient.call{value: amount}(""); require(res, "ENEFTi1155MBPB.14.BNB_TRANSFER_FAILED"); }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~ PUBLIC TRANSFER ~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    * @notice Transfers amount amount of an _id from the _from address to the _to address specified
    * @param _from    Source address
    * @param _to      Target address
    * @param _id      ID of the token type
    * @param _amount  Transfered amount
    * @param _data    Additional data with no specified format, sent in call to `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
        external override
    {
        require(
            _from != address(0) &&
            _to != address(0) &&
            _amount > 0,
            "ENEFTi1155PB.15.INVALID_GIVEN_PARAMETERS"
        );
        require((msg.sender == _from) || operators[_from][msg.sender], "ENEFTi1155PB.16.INVALID_OPERATOR");
        // require(_amount <= balances);  Not necessary since checked with _viewUpdateBinValue() checks

        _safeTransferFrom(_from, _to, _id, _amount);
        _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
    }

    /**
    * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
    * @dev Arrays should be sorted so that all ids in a same storage slot are adjacent (more efficient)
    * @param _from     Source addresses
    * @param _to       Target addresses
    * @param _ids      IDs of each token type
    * @param _amounts  Transfer amounts per token type
    * @param _data     Additional data with no specified format, sent in call to `_to`
    */
    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
        external override
    {
        require(
            _from != address(0) &&
            _to != address(0) &&
            _ids.length > 0 &&
            _amounts.length > 0,
            "ENEFTi1155PB.17.INVALID_GIVEN_PARAMETERS"
        );
        require(_ids.length == _amounts.length, "ENEFTi1155PB.18.INVALID_ARRAYS_LENGTH");
        require((msg.sender == _from) || operators[_from][msg.sender], "ENEFTi1155PB.19.INVALID_OPERATOR");
        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), _data);
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~ INTERNAL TRANSFER ~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    * @notice Transfers amount amount of an _id from the _from address to the _to address specified
    * @param _from    Source address
    * @param _to      Target address
    * @param _id      ID of the token type
    * @param _amount  Transfered amount
    */
    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
        internal
    {
        // Update balances
        _updateIDBalance(_from, _id, _amount, Operations.Sub); // Subtract amount from sender
        _updateIDBalance(_to,   _id, _amount, Operations.Add); // Add amount to recipient
        _setHoldedTokens(_to, _id);
        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    /**
    * @notice Verifies if receiver is contract and if so, calls (_to).onERC1155Received(...)
    */
    function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, uint256 _gasLimit, bytes memory _data)
        internal
    {
        // Check if recipient is contract
        if (_to.isContract()) {
        bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received{gas:_gasLimit}(msg.sender, _from, _id, _amount, _data);
        require(retval == ERC1155_RECEIVED_VALUE, "ENEFTi1155PB.20.INVALID_RECEIVED_VALUE");
        }
    }

    /**
    * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
    * @dev Arrays should be sorted so that all ids in a same storage slot are adjacent (more efficient)
    * @param _from     Source addresses
    * @param _to       Target addresses
    * @param _ids      IDs of each token type
    * @param _amounts  Transfer amounts per token type
    */
    function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
    // function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
        internal
    {
        uint256 nTransfer = _ids.length; // Number of transfer to execute

        if (_from != _to && nTransfer > 0) {
        // Load first bin and index where the token ID balance exists
        (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);

        // Balance for current bin in memory (initialized with first transfer)
        uint256 balFrom = _viewUpdateBinValue(balances[_from][bin], index, _amounts[0], Operations.Sub);
        uint256 balTo = _viewUpdateBinValue(balances[_to][bin], index, _amounts[0], Operations.Add);

        // Last bin updated
        uint256 lastBin = bin;

        uint256 i;
        for (i = 1; i < nTransfer; i++) {
            (bin, index) = getIDBinIndex(_ids[i]);

            // If new bin
            if (bin != lastBin) {
            // Update storage balance of previous bin
            balances[_from][lastBin] = balFrom;
            balances[_to][lastBin] = balTo;

            _setHoldedTokens(_to, _ids[i-1]);
            // _updateIDResources(_ids[i-1], _data);

            balFrom = balances[_from][bin];
            balTo = balances[_to][bin];

            // Bin will be the most recent bin
            lastBin = bin;
            }

            // Update memory balance
            balFrom = _viewUpdateBinValue(balFrom, index, _amounts[i], Operations.Sub);
            balTo = _viewUpdateBinValue(balTo, index, _amounts[i], Operations.Add);
        }

        // Update storage of the last bin visited
        balances[_from][bin] = balFrom;
        balances[_to][bin] = balTo;

        _setHoldedTokens(_to, _ids[i-1]);
        // _updateIDResources(_ids[i-1], _data);

        // If transfer to self, just make sure all amounts are valid
        } else {
        for (uint256 i = 0; i < nTransfer; i++) {
            require(_balanceOf(_from, _ids[i]) >= _amounts[i], "ENEFTi1155PB.21.UNDERFLOW");
        }
        }

        // Emit event
        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    /**
    * @notice Verifies if receiver is contract and if so, calls (_to).onERC1155BatchReceived(...)
    */
    function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, uint256 _gasLimit, bytes memory _data)
        internal
    {
        // Pass data if recipient is contract
        if (_to.isContract()) {
        bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived{gas: _gasLimit}(msg.sender, _from, _ids, _amounts, _data);
        require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ENEFTi1155PB.22.INVALID_BATCH_RECEIVED_VALUE");
        }
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ OPERATOR ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    * @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
    * @param _operator  Address to add to the set of authorized operators
    * @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved)
        external override
    {
        // Update operator status
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
    * @notice Queries the approval status of an operator for a given owner
    * @param _owner     The owner of the Tokens
    * @param _operator  Address of authorized operator
    * @return isOperator True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator)
        external override view returns (bool isOperator)
    { return operators[_owner][_operator]; }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~ PUBLIC BALANCE ~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    * @notice Get the balance of an account's Tokens
    * @param _owner  The address of the token holder
    * @param _id     ID of the Token
    * @return The _owner's balance of the Token type requested
    */
    function balanceOf(address _owner, uint256 _id)
        external override view returns (uint256)
    { return _balanceOf(_owner, _id); }
    function _balanceOf(address _owner, uint256 _id)
        internal view returns (uint256)
    {
        uint256 bin;
        uint256 index;

        //Get bin and index of _id
        (bin, index) = getIDBinIndex(_id);
        return getValueInBin(balances[_owner][bin], index);
    }

    /**
    * @notice Get the balance of multiple account/token pairs
    * @param _owners The addresses of the token holders (sorted owners will lead to less gas usage)
    * @param _ids    ID of the Tokens (sorted ids will lead to less gas usage
    * @return The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
    **/
    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        external override view returns (uint256[] memory)
    {
        require(_owners.length == _ids.length, "ENEFTi1155PB.23.INVALID_ARRAY_LENGTH");
        return _balanceOfBatch(_owners, _ids);
    }
    function _balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        internal view returns (uint256[] memory)
    {
        uint256 n_owners = _owners.length;

        // First values
        (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);
        uint256 balance_bin = balances[_owners[0]][bin];
        uint256 last_bin = bin;

        // Initialization
        uint256[] memory batchBalances = new uint256[](n_owners);
        batchBalances[0] = getValueInBin(balance_bin, index);

        // Iterate over each owner and token ID
        for (uint256 i = 1; i < n_owners; i++) {
        (bin, index) = getIDBinIndex(_ids[i]);

        // SLOAD if bin changed for the same owner or if owner changed
        if (bin != last_bin || _owners[i-1] != _owners[i]) {
            balance_bin = balances[_owners[i]][bin];
            last_bin = bin;
        }

        batchBalances[i] = getValueInBin(balance_bin, index);
        }

        return batchBalances;
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~ PACKED BALANCE ~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    * @notice Update the balance of a id for a given address
    * @param _address    Address to update id balance
    * @param _id         Id to update balance of
    * @param _amount     Amount to update the id balance
    * @param _operation  Which operation to conduct :
    *   Operations.Add: Add _amount to id balance
    *   Operations.Sub: Substract _amount from id balance
    */
    function _updateIDBalance(address _address, uint256 _id, uint256 _amount, Operations _operation)
        internal
    {
        // Get bin and index of _id
        (uint256 bin, uint256 index) = getIDBinIndex(_id);
        // Update balance
        balances[_address][bin] = _viewUpdateBinValue(balances[_address][bin], index, _amount, _operation);
    }

    /**
    * @notice Update a value in _binValues
    * @param _binValues  Uint256 containing values of size IDS_BITS_SIZE (the token balances)
    * @param _index      Index of the value in the provided bin
    * @param _amount     Amount to update the id balance
    * @param _operation  Which operation to conduct :
    *   Operations.Add: Add _amount to value in _binValues at _index
    *   Operations.Sub: Substract _amount from value in _binValues at _index
    */
    function _viewUpdateBinValue(uint256 _binValues, uint256 _index, uint256 _amount, Operations _operation)
        internal pure returns (uint256 newBinValues)
    {
        uint256 shift = IDS_BITS_SIZE * _index;
        uint256 mask = (uint256(1) << IDS_BITS_SIZE) - 1;

        if (_operation == Operations.Add) {
        newBinValues = _binValues + (_amount << shift);
        require(newBinValues >= _binValues, "ENEFTi1155PB.24.OVERFLOW");
        require(
            ((_binValues >> shift) & mask) + _amount < 2**IDS_BITS_SIZE, // Checks that no other id changed
            "ENEFTi1155PB.25.OVERFLOW"
        );

        } else if (_operation == Operations.Sub) {
        newBinValues = _binValues - (_amount << shift);
        require(newBinValues <= _binValues, "ENEFTi1155PB.26.UNDERFLOW");
        require(
            ((_binValues >> shift) & mask) >= _amount, // Checks that no other id changed
            "ENEFTi1155PB.27.UNDERFLOW"
        );

        } else {
        revert("ENEFTi1155PB.28.INVALID_BIN_WRITE_OPERATION"); // Bad operation
        }

        return newBinValues;
    }

    /**
    * @notice Return the bin number and index within that bin where ID is
    * @param _id  Token id
    * @return bin index (Bin number, ID"s index within that bin)
    */
    function getIDBinIndex(uint256 _id)
        public pure returns (uint256 bin, uint256 index)
    {
        bin = _id / IDS_PER_UINT256;
        index = _id % IDS_PER_UINT256;
        return (bin, index);
    }

    /**
    * @notice Return amount in _binValues at position _index
    * @param _binValues  uint256 containing the balances of IDS_PER_UINT256 ids
    * @param _index      Index at which to retrieve amount
    * @return amount at given _index in _bin
    */
    function getValueInBin(uint256 _binValues, uint256 _index)
        public pure returns (uint256)
    {
        // require(_index < IDS_PER_UINT256) is not required since getIDBinIndex ensures `_index < IDS_PER_UINT256`

        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << IDS_BITS_SIZE) - 1;

        // Shift amount
        uint256 rightShift = IDS_BITS_SIZE * _index;
        return (_binValues >> rightShift) & mask;
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~ METADATA INTERNAL ~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @dev Update metadata URI of a Token (internal use)
    ** @param _id ID of the Token
    **/
    function _updateIDResources(uint256 _id, bytes memory _data)
        internal
    {
        uint256 bin;
        uint256 index;

        (bin, index) = getIDBinIndex(_id);

        address minter = minters[bin];

        require(
        msg.sender == owner() ||
        msg.sender == minter ||
        minter == address(0) ||
        minter == address(0x0),
        "ENEFTi1155PB.29.UNAUTHORIZED_MINTER"
        );

        resources[_id] = _data;
    }

    /**
    ** @dev Fetch the metadata URI of a token (internal use)
    ** @param _id           Token id
    ** @return MetadataURI of the Token
    **/
    function _getURI(uint256 _id)
        internal view
        returns (bytes memory)
    { return resources[_id]; }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ ERC-165 ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    * @notice Query if a contract implements an interface
    * @param _interfaceID  The interface identifier, as specified in ERC-165
    * @return `true` if the contract implements `_interfaceID` and
    */
    function supportsInterface(bytes4 _interfaceID)
        public view virtual
        override( ERC165 ) 
        returns (bool)
    {
        if (_interfaceID == type(IERC1155).interfaceId) {
        return true;
        }
        return super.supportsInterface(_interfaceID);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: Apache-2.0
// https://github.com/0xsequence/erc-1155/blob/master/src/contracts/utils/SignatureValidator.sol

pragma solidity >=0.7.4 <=0.8.9;

import "./IERC1271Wallet.sol";
import "./LibBytes.sol";
import "./LibEIP712.sol";

/**
 * @dev Contains logic for signature validation.
 * Signatures from wallet contracts assume ERC-1271 support (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md)
 * Notes: Methods are strongly inspired by contracts in https://github.com/0xProject/0x-monorepo/blob/development/
 */
contract SignatureValidator is LibEIP712 {
  using LibBytes for bytes;

  /***********************************|
  |             Variables             |
  |***********************************/

  // bytes4(keccak256("isValidSignature(bytes,bytes)"))
  bytes4 constant internal ERC1271_MAGICVALUE = 0x20c13b0b;

  // bytes4(keccak256("isValidSignature(bytes32,bytes)"))
  bytes4 constant internal ERC1271_MAGICVALUE_BYTES32 = 0x1626ba7e;

  // uint256 public chainId;
  // address private _cVerify;
  // bytes32 public NCS; // NEFTi Content Salt
  // bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)");
  // bytes32 public constant NEFTi_IDENTITY_TYPEHASH = keccak256("NEFTiIdentity(address wallet,uint256 tokenId,uint256 nonce)");
  // bytes32 public EIP712_DOMAIN_SEPARATOR;

  // Allowed signature types.
  enum SignatureType {
    Illegal,         // 0x00, default value
    EIP712,          // 0x01
    EthSign,         // 0x02
    WalletBytes,     // 0x03 To call isValidSignature(bytes, bytes) on wallet contract
    WalletBytes32,   // 0x04 To call isValidSignature(bytes32, bytes) on wallet contract
    NSignatureTypes  // 0x05, number of signature types. Always leave at end.
  }

  // uint8 private test = 0;
  // event Logger(uint8 log);
  // event Logger(bytes32 log);
  // event Logger(address log);


  /***********************************|
  |        Signature Functions        |
  |***********************************/

  /**
   * @dev Verifies that a hash has been signed by the given signer.
   * @param _signerAddress  Address that should have signed the given hash.
   * @param _hash           Hash of the EIP-712 encoded data
   * @param _data           Full EIP-712 data structure that was hashed and signed
   * @param _sig            Proof that the hash has been signed by signer.
   *      For non wallet signatures, _sig is expected to be an array tightly encoded as
   *      (bytes32 r, bytes32 s, uint8 v, uint256 nonce, SignatureType sigType)
   * @return isValid True if the address recovered from the provided signature matches the input signer address.
   */
  function isValidSignature(
    address _signerAddress,
    bytes32 _hash,
    bytes memory _data,
    bytes memory _sig
  )
    public
    view
    returns (bool isValid, address signer)
  {
    require(
      _sig.length > 0,
      "ENEFTiSV.isValidSignature.LENGTH_GREATER_THAN_0_REQUIRED"
    );

    require(
      _signerAddress != address(0x0),
      "ENEFTiSV.isValidSignature.INVALID_SIGNER"
    );

    // Pop last byte off of signature byte array.
    uint8 signatureTypeRaw = uint8(_sig.popLastByte());

    // Ensure signature is supported
    require(
      signatureTypeRaw < uint8(SignatureType.NSignatureTypes),
      "ENEFTiSV.isValidSignature.UNSUPPORTED_SIGNATURE"
    );

    // Extract signature type
    SignatureType signatureType = SignatureType(signatureTypeRaw);

    // Variables are not scoped in Solidity.
    uint8 v;
    bytes32 r;
    bytes32 s;
    address recovered;

    // Always illegal signature.
    // This is always an implicit option since a signer can create a
    // signature array with invalid type or length. We may as well make
    // it an explicit option. This aids testing and analysis. It is
    // also the initialization value for the enum type.
    if (signatureType == SignatureType.Illegal) {
      revert("ENEFTiSV.isValidSignature.ILLEGAL_SIGNATURE");
    }
    
    // Signature using EIP712
    else if (signatureType == SignatureType.EIP712) {
      require(
        _sig.length == 97,
        "ENEFTiSV.isValidSignature.LENGTH_97_REQUIRED"
      );
      r = _sig.readBytes32(0);
      s = _sig.readBytes32(32);
      v = uint8(_sig[64]);
      recovered = ecrecover(_hash, v, r, s);
      isValid = _signerAddress == recovered;
      return (isValid, recovered);
    }
    
    // Signed using web3.eth_sign() or Ethers wallet.signMessage()
    else if (signatureType == SignatureType.EthSign) {
      require(
        _sig.length == 97,
        "ENEFTiSV.isValidSignature.LENGTH_97_REQUIRED"
      );
      r = _sig.readBytes32(0);
      s = _sig.readBytes32(32);
      v = uint8(_sig[64]);
      recovered = ecrecover(
        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)),
        v,
        r,
        s
      );
      isValid = _signerAddress == recovered;
      return (isValid, recovered);
    }

    // Signature verified by wallet contract with data validation.
    else if (signatureType == SignatureType.WalletBytes) {
      isValid = ERC1271_MAGICVALUE == IERC1271Wallet(_signerAddress).isValidSignature(_data, _sig);
      return (isValid, address(0x0));
    }

    // Signature verified by wallet contract without data validation.
    else if (signatureType == SignatureType.WalletBytes32) {
      isValid = ERC1271_MAGICVALUE_BYTES32 == IERC1271Wallet(_signerAddress).isValidSignature(_hash, _sig);
      return (isValid, address(0x0));
    }

    // Anything else is illegal (We do not return false because
    // the signature may actually be valid, just not in a format
    // that we currently support. In this case returning false
    // may lead the caller to incorrectly believe that the
    // signature was invalid.)
    else { revert("ENEFTiSV.isValidSignature.UNSUPPORTED_SIGNATURE"); }
  }
}

// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.7.4 <=0.8.9;


interface IERC1155 {

  /****************************************|
  |                 Events                 |
  |_______________________________________*/

  /**
   * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
   *   Operator MUST be msg.sender
   *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
   *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
   *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
   *   To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the TransferSingle event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
   */
  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  /**
   * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
   *   Operator MUST be msg.sender
   *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
   *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
   *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
   *   To broadcast the existence of multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
   */
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  /**
   * @dev MUST emit when an approval is updated
   */
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


  /****************************************|
  |                Functions               |
  |_______________________________________*/

  /**
    * @notice Transfers amount of an _id from the _from address to the _to address specified
    * @dev MUST emit TransferSingle event on success
    * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    * MUST throw if `_to` is the zero address
    * MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
    * MUST throw on any other error
    * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    * @param _from    Source address
    * @param _to      Target address
    * @param _id      ID of the token type
    * @param _amount  Transfered amount
    * @param _data    Additional data with no specified format, sent in call to `_to`
    */
  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

  /**
    * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
    * @dev MUST emit TransferBatch event on success
    * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    * MUST throw if `_to` is the zero address
    * MUST throw if length of `_ids` is not the same as length of `_amounts`
    * MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
    * MUST throw on any other error
    * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    * Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
    * @param _from     Source addresses
    * @param _to       Target addresses
    * @param _ids      IDs of each token type
    * @param _amounts  Transfer amounts per token type
    * @param _data     Additional data with no specified format, sent in call to `_to`
  */
  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

  /**
   * @notice Get the balance of an account's Tokens
   * @param _owner  The address of the token holder
   * @param _id     ID of the Token
   * @return        The _owner's balance of the Token type requested
   */
  function balanceOf(address _owner, uint256 _id) external view returns (uint256);

  /**
   * @notice Get the balance of multiple account/token pairs
   * @param _owners The addresses of the token holders
   * @param _ids    ID of the Tokens
   * @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
   */
  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

  /**
   * @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
   * @dev MUST emit the ApprovalForAll event on success
   * @param _operator  Address to add to the set of authorized operators
   * @param _approved  True if the operator is approved, false to revoke approval
   */
  function setApprovalForAll(address _operator, bool _approved) external;

  /**
   * @notice Queries the approval status of an operator for a given owner
   * @param _owner     The owner of the Tokens
   * @param _operator  Address of authorized operator
   * @return isOperator True if the operator is approved, false if not
   */
  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}

// SPDX-License-Identifier: Apache-2.0
/*
  Copyright 2018 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  This is a truncated version of the original LibBytes.sol library from ZeroEx.
*/

pragma solidity >=0.7.4 <=0.8.9;

library LibBytes {
  using LibBytes for bytes;

  /***********************************|
  |        Pop Bytes Functions        |
  |__________________________________*/

  /**
   * @dev Pops the last byte off of a byte array by modifying its length.
   * @param b Byte array that will be modified.
   * @return result The byte that was popped off.
   */
  function popLastByte(bytes memory b)
    internal
    pure
    returns (bytes1 result)
  {
    require(
      b.length > 0,
      "ENEFTiLB__popLastByte__GREATER_THAN_ZERO_LENGTH_REQUIRED"
    );

    // Store last byte.
    result = b[b.length - 1];

    assembly {
      // Decrement length of byte array.
      let newLen := sub(mload(b), 1)
      mstore(b, newLen)
    }
    return result;
  }


  /***********************************|
  |        Read Bytes Functions       |
  |__________________________________*/

  /**
   * @dev Reads a bytes32 value from a position in a byte array.
   * @param b Byte array containing a bytes32 value.
   * @param index Index in byte array of bytes32 value.
   * @return result bytes32 value from byte array.
   */
  function readBytes32(
    bytes memory b,
    uint256 index
  )
    internal
    pure
    returns (bytes32 result)
  {
    require(
      b.length >= index + 32,
      "ENEFTiLB__readBytes32__GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
    );

    // Arrays are prefixed by a 256 bit length parameter
    index += 32;

    // Read the bytes32 from array memory
    assembly {
      result := mload(add(b, index))
    }
    return result;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.7.4 <=0.8.9;


/**
 * @dev ERC-1155 interface for accepting safe transfers.
 */
interface IERC1155TokenReceiver {

  /**
   * @notice Handle the receipt of a single ERC1155 token type
   * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated
   * This function MAY throw to revert and reject the transfer
   * Return of other amount than the magic value MUST result in the transaction being reverted
   * Note: The token contract address is always the message sender
   * @param _operator  The address which called the `safeTransferFrom` function
   * @param _from      The address which previously owned the token
   * @param _id        The id of the token being transferred
   * @param _amount    The amount of tokens being transferred
   * @param _data      Additional data with no specified format
   * @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
   */
  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);

  /**
   * @notice Handle the receipt of multiple ERC1155 token types
   * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated
   * This function MAY throw to revert and reject the transfer
   * Return of other amount than the magic value WILL result in the transaction being reverted
   * Note: The token contract address is always the message sender
   * @param _operator  The address which called the `safeBatchTransferFrom` function
   * @param _from      The address which previously owned the token
   * @param _ids       An array containing ids of each token being transferred
   * @param _amounts   An array containing amounts of each token being transferred
   * @param _data      Additional data with no specified format
   * @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
   */
  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

pragma solidity >=0.7.4 <=0.8.9;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner_;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () {
    _owner_ = msg.sender;
    emit OwnershipTransferred(address(0), _owner_);
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == _owner_, "ENEFTiOA__onlyOwner__SENDER_IS_NOT_OWNER");
    _;
  }

  /**
   * @notice Transfers the ownership of the contract to new address
   * @param _newOwner Address of the new owner
   */
  function transferOwnership(address _newOwner)
    public onlyOwner
  {
    require(_newOwner != address(0), "ENEFTiOA__transferOwnership__INVALID_ADDRESS");
    emit OwnershipTransferred(_owner_, _newOwner);
    _owner_ = _newOwner;
  }

  /**
   * @notice Returns the address of the owner.
   */
  function owner()
    public view
    returns (address)
  { return _owner_; }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;

import "./IERC1155.sol";

interface INEFTiMultiTokens is IERC1155 {

    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Transfers amount of an _id from the _from address to the _to address specified
    ** @dev MUST emit TransferSingle event on success
    ** Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    ** MUST throw if `_to` is the zero address
    ** MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
    ** MUST throw on any other error
    ** When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    ** @param _from    Source address
    ** @param _to      Target address
    ** @param _id      ID of the token type
    ** @param _amount  Transfered amount
    ** @param _data    Additional data with no specified format, sent in call to `_to`
    **/
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external override (IERC1155);

    /**
    ** @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
    ** @dev MUST emit TransferBatch event on success
    ** Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    ** MUST throw if `_to` is the zero address
    ** MUST throw if length of `_ids` is not the same as length of `_amounts`
    ** MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
    ** MUST throw on any other error
    ** When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    ** Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
    ** @param _from     Source addresses
    ** @param _to       Target addresses
    ** @param _ids      IDs of each token type
    ** @param _amounts  Transfer amounts per token type
    ** @param _data     Additional data with no specified format, sent in call to `_to`
    **/
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external override(IERC1155);

    /**
    ** @notice Get the balance of an account's Tokens
    ** @param _owner  The address of the token holder
    ** @param _id     ID of the Token
    ** @return        The _owner's balance of the Token type requested
    **/
    function balanceOf(address _owner, uint256 _id) external view  override(IERC1155) returns (uint256);

    /**
    ** @notice Get the balance of multiple account/token pairs
    ** @param _owners The addresses of the token holders
    ** @param _ids    ID of the Tokens
    ** @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
    **/
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view override(IERC1155) returns (uint256[] memory);

    /**
    ** @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
    ** @dev MUST emit the ApprovalForAll event on success
    ** @param _operator  Address to add to the set of authorized operators
    ** @param _approved  True if the operator is approved, false to revoke approval
    **/
    function setApprovalForAll(address _operator, bool _approved) external override(IERC1155);

    /**
    ** @notice Queries the approval status of an operator for a given owner
    ** @param _owner     The owner of the Tokens
    ** @param _operator  Address of authorized operator
    ** @return isOperator True if the operator is approved, false if not
    **/
    function isApprovedForAll(address _owner, address _operator) external view override(IERC1155) returns (bool isOperator);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~ TOKEN PROPERTIES ~~~~~~~~█║
    ╚════════════════════════════════════*/

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~ MINT & BURN ~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    function mint(address _to, uint256 _id, uint256 _value, bytes memory _data) external payable;

    function batchMint(address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) external payable;

    function burn(address _from, uint256 _id, uint256 _value) external;

    function batchBurn(address _from, uint256[] memory _ids, uint256[] memory _values) external;


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ UTILITIES ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    function requestId() external;

    function totalSupply(uint256 _id) external view returns(uint256);

    function minterOf(uint256 _id) external view returns (address);

    function itemsOf(address _holder) external view returns (uint256[] memory);

    function getMintFee(uint256 amount) external view returns(uint256[3] memory mintFee, uint256 multitokenOnEach, string memory feeAs);

    function getBatchMintFee(uint[] memory _amounts) external view returns(uint256[3] memory mintFee, uint256 multitokenOnEach, string memory feeAs);

}

/**
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface INEFTiMTFeeCalcExt {
    function calculateFee(address holder, uint256 tokenAmount, uint8 fPayMode) external view
        returns(
            uint256 bnbFee,
            uint256 b20Fee,
            uint256 nftFee
        );

    function getBaseFee() external view
        returns(
            uint256[2] memory bnbMinMax,
            uint256[2] memory b20MinMax,
            uint256[2] memory nftMinMax,
            uint256[3] memory nftFee,
            uint256[3] memory multitokenFee,
            uint256 multitokenOnEach,
            string memory feeAs
        );

    function getDivider() external view
        returns(uint256 _defaultDivider);

    function getMintFee(uint256 _amount) external view
        returns(
            uint256[3] memory mintFee,
            uint256 multitokenOnEach,
            string memory feeAs
        );

    function getBatchMintFee(uint[] memory _amounts) external view
        returns(
            uint256[3] memory mintFee,
            uint256 multitokenOnEach,
            string memory feeAs
        );

    function getDefaultPaymentType() external view
        returns(
            uint8 defaultType,
            string memory defaultTypeAsString
        );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.7.4 <=0.8.9;

interface  IERC1271Wallet {
  /**
   * @notice Verifies whether the provided signature is valid with respect to the provided data
   * @dev MUST return the correct magic value if the signature provided is valid for the provided data
   *   > The bytes4 magic value to return when signature is valid is 0x20c13b0b : bytes4(keccak256("isValidSignature(bytes,bytes)")
   *   > This function MAY modify Ethereum's state
   * @param _data       Arbitrary length data signed on the behalf of address(this)
   * @param _signature  Signature byte array associated with _data
   * @return magicValue Magic value 0x20c13b0b if the signature is valid and 0x0 otherwise
   *
   */
  function isValidSignature(
    bytes calldata _data,
    bytes calldata _signature)
    external
    view
    returns (bytes4 magicValue);

  /**
   * @notice Verifies whether the provided signature is valid with respect to the provided hash
   * @dev MUST return the correct magic value if the signature provided is valid for the provided hash
   *   > The bytes4 magic value to return when signature is valid is 0x20c13b0b : bytes4(keccak256("isValidSignature(bytes,bytes)")
   *   > This function MAY modify Ethereum's state
   * @param _hash       keccak256 hash that was signed
   * @param _signature  Signature byte array associated with _data
   * @return magicValue Magic value 0x20c13b0b if the signature is valid and 0x0 otherwise
   */
  function isValidSignature(
    bytes32 _hash,
    bytes calldata _signature)
    external
    view
    returns (bytes4 magicValue);
}

// SPDX-License-Identifier: Apache-2.0
// https://github.com/0xsequence/erc-1155/blob/master/src/contracts/utils/LibEIP712.sol

/**
 * Copyright 2018 ZeroEx Intl.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *   http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity >=0.7.4 <=0.8.9;


contract LibEIP712 {

  /***********************************|
  |             Constants             |
  |__________________________________*/

  // keccak256( "EIP712Domain(address verifyingContract)" );
  bytes32 internal constant DOMAIN_SEPARATOR_TYPEHASH = 0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;

  // EIP-191 Header
  string constant internal EIP191_HEADER = "\\x19\\x01";

  /***********************************|
  |          Hashing Function         |
  |__________________________________*/

  /**
   * @dev Calculates EIP712 encoding for a hash struct in this EIP712 Domain.
   * @param hashStruct The EIP712 hash struct.
   * @return result EIP712 hash applied to this EIP712 Domain.
   */
  function hashEIP712Message(bytes32 hashStruct)
      internal
      view
      returns (bytes32 result)
  {
    return keccak256(
      abi.encodePacked(
        EIP191_HEADER,
        keccak256(
          abi.encode(
            DOMAIN_SEPARATOR_TYPEHASH,
            address(this)
          )
        ),
        hashStruct
    ));
  }
}