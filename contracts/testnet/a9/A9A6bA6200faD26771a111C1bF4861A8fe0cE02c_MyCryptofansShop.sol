/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract MyCryptofansShop {
    address private token;
    uint256 public lastId;
    uint256 public comision;
    address private owner;
    address payable ownerComision;

    struct Product {
        uint256 id;
        string title;
        uint256 date;
        address payable owner;
        uint256 price;
        uint256 priceComision;
        uint256 priceTotal;
    }

    Product[] public products;

    address[] public sellers;

    uint256 public sellerCount;
    mapping(address => bool) public existsSellers;
    mapping(address => uint256[]) public sellerProducts;
    mapping(address => bool) public blackList;

    mapping(address => uint256) public sellerProductCount;

    mapping(uint256 => Product) public productById;
    mapping(uint256 => address[]) public clientById;
    mapping(uint256 => uint256) public clientByIdCount;
    mapping(uint256 => mapping(address => bool)) public clientByIdExist;
    mapping(uint256 => bool) public productActive;
    mapping(uint256 => uint256) public productAmount;
    mapping(address => uint256) public amountBySeller;
    uint256 public amount;

    uint256 public purchasesCount;
    address[] public clients;
    uint256 public clientsCount;
    mapping(address => bool) public existsClient;
    mapping(address => uint256[]) public clientProducts;
    mapping(address => mapping(uint256 => bool)) public existsClientProduct;
    mapping(address => uint256) public clientProductsCount;
    mapping(address => uint256) public clientPurchasesCount; //total de shops realizados

    mapping(address => address[]) public clientSellers;
    mapping(address => uint256) public clientSellersCount;
    mapping(address => mapping(address => bool)) public existsClientSellers;

    mapping(address => mapping(uint256 => bool)) public existClientProducts;
    mapping(address => mapping(uint256 => uint256))
        public clientDateByIdProducts; //fecha ultimo shop
    mapping(address => mapping(uint256 => uint256))
        public clientProductsPurchases; //total de compra del mismo shop
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        public clientDateByCount; //fecha de cada shop
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        public clientDateByTotalCount; //fecha de cada shop

    constructor(address _token, uint256 _commision) {
        owner = msg.sender;
        token = _token;
        ownerComision = msg.sender;
        comision = _commision;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    event createShop(
        address indexed ownerShop,
        uint256 indexed idProduct,
        uint256 indexed date,
        uint256 price,
        uint256 priceComision
    );
    event buyShop(
        address indexed ownerClient,
        address indexed ownerSeller,
        uint256 indexed idProduct,
        uint256 date
    );

    function setblakList(address _addressBlack) public isOwner {
        blackList[_addressBlack] = true;
    }

    function retireblakList(address _addressBlack) public isOwner {
        blackList[_addressBlack] = false;
    }

    function setOwnerComsion(address _ownerComision) public isOwner {
        ownerComision = payable(_ownerComision);
    }

    function setComision(uint256 _comision) public isOwner {
        comision = _comision;
    }

    function setToken(address _token) public isOwner {
        token = _token;
    }

    function publishShop(string memory _title, uint256 _price) public {
        require(!blackList[msg.sender], "crear Desactivado");
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_price > 0, "price cannot be minor to 1");
        uint256 myid = lastId++;

        Product memory p = Product(
            myid,
            _title,
            block.timestamp,
            payable(msg.sender),
            _price * 1e18,
            ((_price * 1e18) / comision),
            (_price * 1e18 + (_price * 1e18) / comision)
        );
        products.push(p);
        sellerProducts[msg.sender].push(p.id);
        productById[myid] = p;
        productActive[myid] = true;
        sellerProductCount[msg.sender]++;

        if (!existsSellers[msg.sender]) {
            sellers.push(msg.sender);
            sellerCount++;
            existsSellers[msg.sender] = true;
        }

        emit createShop(
            p.owner,
            p.id,
            block.timestamp,
            p.price,
            p.priceComision
        );
    }

    function shopStop(uint256 _id) public isOwner {
        productActive[_id] = false;
    }

    function shopStart(uint256 _id) public isOwner {
        productActive[_id] = true;
    }

    function sellerStop(uint256 _id) public {
        Product memory product = productById[_id];
        require(product.owner == msg.sender, "Only seller can mark stop");
        productActive[_id] = false;
    }

    function sellerShopStart(uint256 _id) public {
        Product memory product = productById[_id];
        require(product.owner == msg.sender, "Only seller can mark start");
        productActive[_id] = true;
    }

    function getSellerAddress() public view returns (address[] memory) {
        return sellers;
    }

    function getSellers(uint256 from, uint256 to)
        public
        view
        returns (address[] memory)
    {
        address[] memory addressData = new address[](to - from);

        require(sellerCount >= from, "from es mayor al count");
        require(sellerCount >= to, "to es mayor al count");
        require(to >= from, "from no puede ser menor que to");

        for (uint256 i = from; i < to; i++) {
            addressData[i] = sellers[i];
        }
        return (addressData);
    }

    function getSellerByClient(address _address)
        public
        view
        returns (address[] memory)
    {
        address[] memory sellersList = new address[](
            clientSellersCount[_address]
        );

        for (uint256 i = 0; i < clientSellersCount[_address]; i++) {
            sellersList[i] = clientSellers[_address][i];
        }
        return (sellersList);
    }

    function getClientByProduct(uint256 _id)
        public
        view
        returns (address[] memory)
    {
        address[] memory clientList = new address[](clientByIdCount[_id]);

        for (uint256 i = 0; i < clientByIdCount[_id]; i++) {
            clientList[i] = clientById[_id][i];
        }
        return (clientList);
    }

    function getProductByClient(
        uint256 from,
        uint256 to,
        address _address
    )
        public
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        require(
            clientProductsCount[_address] >= from,
            "from es mayor al count"
        );
        require(clientProductsCount[_address] >= to, "to es mayor al count");
        require(to >= from, "from no puede ser menor que to");

        uint256[] memory idProducts = new uint256[](
            clientProductsCount[_address]
        );
        uint256[] memory date = new uint256[](clientProductsCount[_address]);
        uint256[] memory countPurchases = new uint256[](
            clientProductsCount[_address]
        );
        bool[] memory isActive = new bool[](clientProductsCount[_address]);

        for (uint256 i = 0; i < clientProductsCount[_address]; i++) {
            idProducts[i] = clientProducts[_address][i];
            date[i] = clientDateByIdProducts[_address][
                clientProducts[_address][i]
            ];
            countPurchases[i] = clientProductsPurchases[_address][
                clientProducts[_address][i]
            ];
            isActive[i] = productActive[idProducts[i]];
        }
        return (idProducts, date, countPurchases, isActive);
    }

    function getProductBySeller(
        uint256 from,
        uint256 to,
        address _address
    )
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        require(sellerProductCount[_address] >= from, "from es mayor al count");
        require(sellerProductCount[_address] >= to, "to es mayor al count");
        require(to >= from, "from no puede ser menor que to");

        uint256[] memory id = new uint256[](to - from);
        string[] memory title = new string[](to - from);
        string[] memory description = new string[](to - from);
        uint256[] memory date = new uint256[](to - from);
        uint256[] memory price = new uint256[](to - from);
        bool[] memory isActive = new bool[](to - from);

        for (uint256 i = from; i < to; i++) {
            id[i] = sellerProducts[_address][i];
            title[i] = productById[id[i]].title;
            date[i] = productById[id[i]].date;
            price[i] = productById[id[i]].priceTotal;
            isActive[i] = productActive[id[i]];
        }
        return (id, title, description, date, price, isActive);
    }

    function payPurchaseOrder(uint256 _id) public {
        IERC20 TOKEN = IERC20(token);
        require(productActive[_id], "producto no activo");
        require(
            TOKEN.balanceOf(msg.sender) >
                (productById[_id].price + productById[_id].priceComision),
            "Saldo insuficiente"
        );
        require(
            TOKEN.allowance(msg.sender, address(this)) >=
                (productById[_id].price + productById[_id].priceComision),
            "Sin permisos de retiro, cancelar pago"
        );

        require(
            TOKEN.balanceOf(msg.sender) >=
                (productById[_id].price + productById[_id].priceComision),
            "Saldo insuficiente"
        );
        require(
            TOKEN.transferFrom(
                msg.sender,
                productById[_id].owner,
                productById[_id].price
            ),
            "falla critica owner"
        );
        require(
            TOKEN.transferFrom(
                msg.sender,
                ownerComision,
                productById[_id].priceComision
            ),
            "falla critica ownercomision"
        );

        if (!existsClient[msg.sender]) {
            clients.push(msg.sender);
            clientsCount++;
            existsClient[msg.sender] = true;
            clientSellersCount[msg.sender]++;
        }

        if (!existsClientSellers[msg.sender][productById[_id].owner]) {
            clientSellers[msg.sender].push(productById[_id].owner);
            existsClientSellers[msg.sender][productById[_id].owner] = true;
        }

        if (!existClientProducts[msg.sender][_id]) {
            clientProducts[msg.sender].push(_id);
            clientProductsCount[msg.sender]++;
            existClientProducts[msg.sender][_id] = true;
        }

        if (!clientByIdExist[_id][msg.sender]) {
            clientById[_id].push(msg.sender);
            clientByIdCount[_id]++;
            clientByIdExist[_id][msg.sender] = true;
        }

        clientDateByIdProducts[msg.sender][_id] = block.timestamp;
        clientProductsPurchases[msg.sender][_id]++;
        clientPurchasesCount[msg.sender]++;
        clientDateByTotalCount[msg.sender][_id][
            clientPurchasesCount[msg.sender]
        ] = clientDateByIdProducts[msg.sender][_id];
        clientDateByCount[msg.sender][_id][
            clientProductsPurchases[msg.sender][_id]
        ] = clientDateByIdProducts[msg.sender][_id];
        purchasesCount++;

        productAmount[_id] += productById[_id].price;
        amountBySeller[productById[_id].owner] += productById[_id].price;
        amount += productById[_id].price;

        emit buyShop(msg.sender, productById[_id].owner, _id, block.timestamp);
    }

    function getbal() public view returns (uint256) {
        IERC20 USDT = IERC20(token);
        return USDT.balanceOf(msg.sender);
    }
}