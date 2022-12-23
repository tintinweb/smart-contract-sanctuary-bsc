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

contract MFETTransformFromTokenGo {
    address private _owner;

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTransform(
        address indexed user,
        string indexed tokenType,
        uint256 transform,
        uint256 timestamp
    );
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    mapping(string => uint256) private treePrices;

    /*=================================
     =            DATASETS            =
     ================================*/
    mapping(address => mapping(string => uint256))
        private tokenTransformLedger_;

    mapping(string => uint256) private totalTransformToken_;

    IBEP20 private bToken;

    constructor(address _bToken) {
        _owner = msg.sender;
        bToken = IBEP20(_bToken);

        // initialize
        treePrices["air"] = 100;
        treePrices["soil"] = 100;
        treePrices["ocean"] = 100;
        treePrices["animal"] = 100;
        treePrices["tree"] = 100;
        treePrices["special"] = 100;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    /*=======================================
    =            CONSTANT FUNCTIONS         =
    =======================================*/
    function changeBalanceToken(address _bToken) external onlyOwner {
        require(_bToken != address(0), "zero address");
        bToken = IBEP20(_bToken);
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
    =            CONSTANT FUNCTIONS         =
    =======================================*/
    /// @dev change min service fee of token
    function changeTreePriceForTokens(
        uint8 _air,
        uint8 _soil,
        uint8 _ocean,
        uint8 _animal,
        uint8 _tree,
        uint8 _special
    ) public onlyOwner {
        require(
            _air > 0 &&
                _soil > 0 &&
                _ocean > 0 &&
                _animal > 0 &&
                _tree > 0 &&
                _special > 0,
            "amounts needs to be positive"
        );

        treePrices["air"] = _air;
        treePrices["soil"] = _soil;
        treePrices["ocean"] = _ocean;
        treePrices["animal"] = _animal;
        treePrices["tree"] = _tree;
        treePrices["special"] = _special;
    }

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    function transform(
        uint256 _amount,
        address _user,
        string memory _type
    ) external onlyOwner {
        transformTokens(_amount, _type, _user);
        emit onTransform(_user, _type, _amount, block.timestamp);
    }

    /// @dev Retrieve the total transform amount
    function totalTransformToken(string memory _type)
        external
        view
        returns (uint256)
    {
        return totalTransformToken_[_type];
    }

    /// @dev Retrieve the token transform data of mfet token any single address.
    function totalTransformWithAddress(address _address, string memory _type)
        public
        view
        returns (uint256)
    {
        return tokenTransformLedger_[_address][_type];
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function transformTokens(
        uint256 _amount,
        string memory _type,
        address _user
    ) internal {
        require(treePrices[_type] > 0, "type should be correct");

        // calculation
        uint256 treePrice = treePrices[_type];
        uint256 tokenToTransform = _amount / treePrice;

        tokenTransformLedger_[_user][_type] += tokenToTransform;
        // add to globals
        totalTransformToken_[_type] += tokenToTransform;

        bToken.transfer(_user, tokenToTransform);
    }
}