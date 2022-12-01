// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./interfaces/OperatorV2.sol";
import "./interfaces/ISeqNFT.sol";

import "./utils/SeqIdentifier.sol";
import "./utils/ERC1155.sol";
import "./utils/EnumerableMap.sol";
import "./utils/Strings.sol";

contract SeqNFT is ISeqNFT, ERC1155, OperatorV2 {
    using EnumerableMap for EnumerableMap.Map;

    event GenesisActivated(address indexed owner, uint256 id);

    EnumerableMap.Map _genesisOwner;

    mapping(uint256 => uint256) public activationDeadlines;
    mapping(uint256 => uint256) public deadlines;
    mapping(uint256 => string) _customUri;

    uint56 _lastId = 0;
    string _uri;

    uint8 public constant MAX_GENESIS = 50;

    constructor(string memory uri_) {
        _uri = uri_;
    }

    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (keccak256(bytes(_customUri[id])) != keccak256(bytes(""))) {
            return _customUri[id];
        }
        return
            string(
                abi.encodePacked(
                    _uri,
                    Strings.toString(id >> SeqIdentifier.INDEX_BITS)
                )
            );
    }

    function setURI(uint256 id, string memory uri_) external isOperator {
        _customUri[id] = uri_;
        emit URI(uri_, id);
    }

    function setBaseURI(string memory uri_) external isOperator {
        _uri = uri_;
    }

    function mintGenesis(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        (bool exists, uint256 id) = _genesisOwner.get(to);
        if (exists) {
            require(
                _genesisState(block.timestamp, id) == 3,
                "genesis balance > 0"
            );
            if (activationDeadlines[id] != 0) {
                delete activationDeadlines[id];
            }
            delete deadlines[id];
        } else {
            uint256 len = _genesisOwner.length();
            if (len >= MAX_GENESIS) {
                require(
                    _burnGenesisOutdated(),
                    "genesis balance >= MAX_GENESIS"
                );
            }
        }
        id = _mintOne(to, SeqIdentifier.TYPE_G);
        activationDeadlines[id] = block.timestamp + 30 days;
        _genesisOwner.set(to, id);
        return id;
    }

    function genesisTotal() external view override returns (uint256) {
        uint256 total = 0;
        uint256 len = _genesisOwner.length();
        for (uint256 i = 0; i < len; i++) {
            (, uint256 id) = _genesisOwner.at(i);
            uint256 state = _genesisState(block.timestamp, id);
            if (state == 1 || state == 2) {
                total++;
            }
        }
        return total;
    }

    function mintStorage(address to, uint256 count)
        external
        override
        isOperator
    {
        _mint(to, SeqIdentifier.TYPE_S, count, "");
    }

    function burnStorage(address owner, uint256 count)
        external
        override
        isOperator
    {
        _burn(owner, SeqIdentifier.TYPE_S, count);
    }

    function mintBonus(address to)
        public
        override
        isOperator
        returns (uint256)
    {
        return _mintNFT(to, SeqIdentifier.TYPE_B, block.timestamp + 180 days);
    }

    function mintProfit(address to)
        public
        override
        isOperator
        returns (uint256)
    {
        return _mintNFT(to, SeqIdentifier.TYPE_PA, block.timestamp + 180 days);
    }

    function mintPieceS1(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_S1, 1, "");
        return SeqIdentifier.TYPE_S1;
    }

    function mintPieceS2(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_S2, 1, "");
        return SeqIdentifier.TYPE_S2;
    }

    function mintPieceS3(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_S3, 1, "");
        return SeqIdentifier.TYPE_S3;
    }

    function mintPieceS4(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_S4, 1, "");
        return SeqIdentifier.TYPE_S4;
    }

    function mintPieceB1(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_B1, 1, "");
        return SeqIdentifier.TYPE_B1;
    }

    function mintPieceB2(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_B2, 1, "");
        return SeqIdentifier.TYPE_B2;
    }

    function mintPieceB3(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_B3, 1, "");
        return SeqIdentifier.TYPE_B3;
    }

    function mintPieceB4(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_B4, 1, "");
        return SeqIdentifier.TYPE_B4;
    }

    function mintPieceB5(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_B5, 1, "");
        return SeqIdentifier.TYPE_B5;
    }

    function mintPieceP1(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_P1, 1, "");
        return SeqIdentifier.TYPE_P1;
    }

    function mintPieceP2(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_P2, 1, "");
        return SeqIdentifier.TYPE_P2;
    }

    function mintPieceP3(address to)
        external
        override
        isOperator
        returns (uint256)
    {
        _mint(to, SeqIdentifier.TYPE_P3, 1, "");
        return SeqIdentifier.TYPE_P3;
    }

    // build

    function buildS(address to) external override isOperator {
        _burn(to, SeqIdentifier.TYPE_S1, 1);
        _burn(to, SeqIdentifier.TYPE_S2, 1);
        _burn(to, SeqIdentifier.TYPE_S3, 1);
        _burn(to, SeqIdentifier.TYPE_S4, 1);
    }

    function buildB(address to) external override isOperator {
        buildB(to, 0);
    }

    function buildB(address to, uint256 id) public override isOperator {
        if (id != 0) {
            require(
                SeqIdentifier.isTypeB(id) &&
                    balanceOf(to, id) > 0 &&
                    deadlines[id] < block.timestamp,
                "invalid id"
            );
            _burnNFT(to, id);
        } else {
            _burn(to, SeqIdentifier.TYPE_B1, 1);
        }
        _burn(to, SeqIdentifier.TYPE_B2, 1);
        _burn(to, SeqIdentifier.TYPE_B3, 1);
        _burn(to, SeqIdentifier.TYPE_B4, 1);
        _burn(to, SeqIdentifier.TYPE_B5, 1);
        mintBonus(to);
    }

    function buildP(address to) external override isOperator {
        buildP(to, 0, 0, 0);
    }

    function buildP(
        address to,
        uint256 id,
        uint256 id1,
        uint256 id2
    ) public override isOperator {
        if (id != 0) {
            require(
                SeqIdentifier.isTypePA(id) &&
                    balanceOf(to, id) > 0 &&
                    deadlines[id] < block.timestamp,
                "invalid id"
            );
            _burnNFT(to, id);
        } else {
            _burn(to, SeqIdentifier.TYPE_P3, 1);
        }
        if (id1 != 0) {
            require(
                (SeqIdentifier.isTypePB(id1) || SeqIdentifier.isTypePC(id1)) &&
                    balanceOf(to, id1) > 0 &&
                    deadlines[id1] < block.timestamp,
                "invalid id"
            );
            _burnNFT(to, id1);
        } else {
            _burn(to, SeqIdentifier.TYPE_P2, 1);
        }
        if (id2 != 0) {
            require(
                SeqIdentifier.isTypePD(id2) &&
                    balanceOf(to, id2) > 0 &&
                    deadlines[id2] < block.timestamp,
                "invalid id"
            );
            _burnNFT(to, id2);
        } else {
            _burn(to, SeqIdentifier.TYPE_P1, 1);
        }
        mintProfit(to);
    }

    // upgrade

    function upgradeProfit(
        address to,
        uint256 id0,
        uint256 id1
    ) external override isOperator returns (uint8) {
        if (SeqIdentifier.isTypePA(id0) && SeqIdentifier.isTypePA(id1)) {
            _upgrade(to, id0, id1, SeqIdentifier.TYPE_PB);
            return 1;
        } else if (
            (SeqIdentifier.isTypePA(id0) && SeqIdentifier.isTypePB(id1)) ||
            (SeqIdentifier.isTypePA(id1) && SeqIdentifier.isTypePB(id0)) ||
            (SeqIdentifier.isTypePB(id0) && SeqIdentifier.isTypePB(id1))
        ) {
            _upgrade(to, id0, id1, SeqIdentifier.TYPE_PC);
            return 2;
        } else if (
            (SeqIdentifier.isTypePB(id0) && SeqIdentifier.isTypePC(id1)) ||
            (SeqIdentifier.isTypePB(id1) && SeqIdentifier.isTypePC(id0)) ||
            (SeqIdentifier.isTypePC(id0) && SeqIdentifier.isTypePC(id1))
        ) {
            _upgrade(to, id0, id1, SeqIdentifier.TYPE_PD);
            return 3;
        }
        revert("invalid id");
    }

    // genesis utils

    function activateGenesis(address who) external override isOperator {
        (bool exists, uint256 id) = _genesisOwner.get(who);
        if (exists) {
            if (activationDeadlines[id] != 0) {
                delete activationDeadlines[id];
            }
            deadlines[id] = block.timestamp + 30 days;
            emit GenesisActivated(who, id);
        }
    }

    // 0: not genesis
    // 1: not activated
    // 2: activated
    // 3: outdated
    function genesisState(address who) external view override returns (uint8) {
        (bool exists, uint256 id) = _genesisOwner.get(who);
        if (!exists) {
            return 0;
        }
        return _genesisState(block.timestamp, id);
    }

    // private

    function _burnGenesis(address owner) private {
        (uint256 id, bool ok) = _genesisOwner.remove(owner);
        if (ok) {
            delete activationDeadlines[id];
            delete deadlines[id];
            _burn(owner, id, 1);
        }
    }

    function _burnGenesisOutdated() private returns (bool) {
        uint256 len = _genesisOwner.length();
        for (uint256 i = 0; i < len; i++) {
            (address addr, uint256 id) = _genesisOwner.at(i);
            uint256 state = _genesisState(block.timestamp, id);
            if (state == 1 || state == 2) {
                continue;
            }
            _burnGenesis(addr);
            return true;
        }
        return false;
    }

    function _max(uint256 a, uint256 b) private pure returns (uint256) {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

    function _upgrade(
        address to,
        uint256 id0,
        uint256 id1,
        uint256 typ
    ) private {
        uint256 deadline1 = deadlines[id0];
        uint256 deadline2 = deadlines[id1];

        if (block.timestamp > deadline1 || block.timestamp > deadline2) {
            revert("token expired");
        }

        uint256 deadline = _max(deadline1, deadline2);
        _burnNFT(to, id0);
        _burnNFT(to, id1);
        _mintNFT(to, typ, deadline);
    }

    function _genesisState(uint256 time, uint256 id)
        private
        view
        returns (uint8)
    {
        uint256 ad = activationDeadlines[id];
        if (ad > 0 && time <= ad) {
            return 1;
        }
        if (time <= deadlines[id]) {
            return 2;
        }
        return 3;
    }

    function _mintNFT(
        address to,
        uint256 ty,
        uint256 deadline
    ) private returns (uint256) {
        uint256 id = _mintOne(to, ty);
        deadlines[id] = deadline;
        return id;
    }

    function _burnNFT(address owner, uint256 id) private {
        _burn(owner, id, 1);
        delete deadlines[id];
    }

    function _mintOne(address to, uint256 typ) private returns (uint256) {
        uint256 id = typ + uint256(uint56(++_lastId));
        _mint(to, id, 1, "");
        return id;
    }

    function _beforeTokenTransfer(
        address,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory,
        bytes memory
    ) internal virtual override {
        if (from == address(0) || to == address(0)) {
            // mint or burn
            return;
        }
        for (uint256 i = 0; i < ids.length; i++) {
            if (ids[i] == SeqIdentifier.TYPE_S) {
                revert("storage nft not transferable");
            }
            if (SeqIdentifier.isTypeG(ids[i])) {
                (uint256 id, bool ok) = _genesisOwner.remove(from);
                require(ok, "no genesis nft");
                require(_genesisOwner.set(to, id), "has genesis nft");
            }
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library SeqIdentifier {
    uint8 public constant INDEX_BITS = 56;

    uint256 public constant TYPE_MASK = uint256(-1) << INDEX_BITS;

    uint256 public constant TYPE_G = uint256(10) << INDEX_BITS;

    uint256 public constant TYPE_S = uint256(20) << INDEX_BITS;
    uint256 public constant TYPE_S1 = uint256(21) << INDEX_BITS;
    uint256 public constant TYPE_S2 = uint256(22) << INDEX_BITS;
    uint256 public constant TYPE_S3 = uint256(23) << INDEX_BITS;
    uint256 public constant TYPE_S4 = uint256(24) << INDEX_BITS;

    uint256 public constant TYPE_B = uint256(30) << INDEX_BITS;
    uint256 public constant TYPE_B1 = uint256(31) << INDEX_BITS;
    uint256 public constant TYPE_B2 = uint256(32) << INDEX_BITS;
    uint256 public constant TYPE_B3 = uint256(33) << INDEX_BITS;
    uint256 public constant TYPE_B4 = uint256(34) << INDEX_BITS;
    uint256 public constant TYPE_B5 = uint256(35) << INDEX_BITS;

    uint256 public constant TYPE_PA = uint256(40) << INDEX_BITS;
    uint256 public constant TYPE_PB = uint256(41) << INDEX_BITS;
    uint256 public constant TYPE_PC = uint256(42) << INDEX_BITS;
    uint256 public constant TYPE_PD = uint256(43) << INDEX_BITS;

    uint256 public constant TYPE_P1 = uint256(45) << INDEX_BITS;
    uint256 public constant TYPE_P2 = uint256(46) << INDEX_BITS;
    uint256 public constant TYPE_P3 = uint256(47) << INDEX_BITS;

    function isTypeG(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_G;
    }

    function isTypeB(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_B;
    }

    function isTypePA(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PA;
    }

    function isTypePB(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PB;
    }

    function isTypePC(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PC;
    }

    function isTypePD(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PD;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "../interfaces/IERC165.sol";
import "../interfaces/IERC1155.sol";
import "../interfaces/IERC1155MetadataURI.sol";
import "../interfaces/IERC1155Receiver.sol";

import "./Address.sol";
import "./SafeMath.sol";

contract ERC1155 is IERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;
    using SafeMath for uint256;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId;
    }

    function uri(uint256) public view virtual override returns (string memory) {
        return "";
    }

    function balanceOf(address account, uint256 id)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            account != address(0),
            "ERC1155: address zero is not a valid owner"
        );
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(
            fromBalance >= amount,
            "ERC1155: insufficient balance for transfer"
        );
        // unchecked {
        _balances[id][from] = fromBalance - amount;
        // }
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
            // unchecked {
            _balances[id][from] = fromBalance - amount;
            // }
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = msg.sender;
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] = amount.add(_balances[id][to]);

        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            id,
            amount,
            data
        );
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = msg.sender;

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = msg.sender;
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        // unchecked {
        _balances[id][from] = fromBalance - amount;
        // }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: burn amount exceeds balance"
            );
            // unchecked {
            _balances[id][from] = fromBalance - amount;
            // }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver.onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library EnumerableMap {
    struct Map {
        address[] _keys;
        mapping(address => uint256) _indexes;
        mapping(address => uint256) _values;
    }

    function set(Map storage obj, address key, uint256 value) internal returns (bool) {
        obj._values[key] = value;
        if (!contains(obj, key)) {
            obj._keys.push(key);
            obj._indexes[key] = obj._keys.length;
            return true;
        }
        return false;
    }

    function remove(Map storage obj, address key) internal returns(uint256, bool) {
        uint256 valueIndex = obj._indexes[key];
        if (valueIndex != 0) {
            delete obj._indexes[key];

            uint256 old = obj._values[key];
            delete obj._values[key];

            uint256 oldIndex = obj._keys.length - 1;
            uint256 newIndex = valueIndex - 1;
            if (oldIndex != newIndex) {
                address oldKey = obj._keys[oldIndex];
                obj._keys[newIndex] = oldKey;
                obj._indexes[oldKey] = valueIndex;
            }
            obj._keys.pop();
            return (old, true);
        }
        return (0, false);
    }

    function contains(Map storage obj, address key) internal view returns (bool) {
        return obj._indexes[key] != 0;
    }

    function length(Map storage obj) internal view returns (uint256) {
        return obj._keys.length;
    }

    function at(Map storage obj, uint256 index) internal view returns (address, uint256) {
        address key = obj._keys[index];
        return (key, obj._values[key]);
    }

    function get(Map storage obj, address key) internal view returns (bool, uint256) {
        uint256 value = obj._values[key];
        if (value == 0) {
            return (contains(obj, key), 0);
        } else {
            return (true, value);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface ISeqNFT {
    function activateGenesis(address who) external;

    function genesisState(address who) external view returns (uint8);

    function genesisTotal() external view returns (uint256);

    function mintGenesis(address to) external returns (uint256);

    function mintBonus(address to) external returns (uint256);

    function mintProfit(address to) external returns (uint256);

    function mintStorage(address to, uint256 count) external;

    function mintPieceS1(address to) external returns (uint256);

    function mintPieceS2(address to) external returns (uint256);

    function mintPieceS3(address to) external returns (uint256);

    function mintPieceS4(address to) external returns (uint256);

    function mintPieceB1(address to) external returns (uint256);

    function mintPieceB2(address to) external returns (uint256);

    function mintPieceB3(address to) external returns (uint256);

    function mintPieceB4(address to) external returns (uint256);

    function mintPieceB5(address to) external returns (uint256);

    function mintPieceP1(address to) external returns (uint256);

    function mintPieceP2(address to) external returns (uint256);

    function mintPieceP3(address to) external returns (uint256);

    function buildS(address to) external;

    function buildB(address to) external;

    function buildB(address to, uint256 id) external;

    function buildP(address to) external;

    function buildP(
        address to,
        uint256 id,
        uint256 id1,
        uint256 id2
    ) external;

    function upgradeProfit(
        address to,
        uint256 id0,
        uint256 id1
    ) external returns (uint8);

    function burnStorage(address owner, uint256 count) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

/**
 * @dev String operations.
 */
library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./IERC1155.sol";

interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./IERC165.sol";

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./IERC165.sol";

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errMsg
    ) internal pure returns (uint256) {
        require(b <= a, errMsg);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library Address {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
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