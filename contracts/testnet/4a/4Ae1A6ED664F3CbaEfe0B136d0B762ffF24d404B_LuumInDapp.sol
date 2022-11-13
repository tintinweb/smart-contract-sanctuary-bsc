// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract LuumInDapp{
        
    // Instancias del contato
    ERC20LuumIn private token;
    uint private tokenPrice;

    uint256 private productsCounter = 0;
    uint256 private contractsCounter = 0;
    uint256 private totalUsers = 0;
    
    address payable public owner;
    address private contrato;
    uint private tokensVendidos;

    Producto[] private MapProducts;
    cliente[] private MapClients;
    Contrato[] private MapContracts;
    

    


    
    
    constructor (address _token) public {
        token = ERC20LuumIn(_token);
        owner = msg.sender;
        contrato = address(this);
        tokenPrice = 0.000057 * 10 **18;
    }

    function getAddressOwner() public view returns (address) {
        return owner;
    }
    
    function getAddressContract() public view returns (address){
        return contrato;
    }

    function __isOwner() public view returns (bool){
        return msg.sender == owner;
    }

     modifier Unicamente(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion.");
        _;
    }



    event ComprandoTokens (
        uint,
        address
    );

    event otorgando_tokens (
        address,
        uint
    );

    event updatingTokenPrice (
        uint
    );

    
    
    
    
    // --------------------------------- GESTION DE TOKENS ---------------------------------

    function CompraTokens(uint _numTokens) public payable {
        uint coste = _numTokens*tokenPrice;
        require (msg.value >= coste, "Compra menos Tokens o paga con mas ethers.");
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);
        uint Balance = TokensDisponibles();
        require(_numTokens <= Balance, "Compra un numero menor de Tokens");
        token.transfer(msg.sender, __amount(_numTokens));
        MappingClientes[msg.sender].tokens_comprados += _numTokens;
        tokensVendidos += _numTokens;
        
        emit ComprandoTokens(_numTokens, msg.sender);
    }

    function _tokenPrice() external view returns (uint) {
        return tokenPrice;
    }

    function updateTokenPrice(uint newTokenPrice) public Unicamente (msg.sender) {
        tokenPrice = newTokenPrice;

        emit updatingTokenPrice(newTokenPrice);
    }

     function totalSupply() public view returns(uint){
        return __unAmount(token.totalSupply(), 18);
    }
    
    function TokensDisponibles() public view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    function CustomerTokens(address _propietario) public view returns (uint){
        return token.balanceOf(_propietario);
    }

    function MisTokens() public view returns (uint){
        return __unAmount(token.balanceOf(msg.sender),18);
    }

     function TokensVendidos() external view returns (uint) {
        return tokensVendidos;
    }

    //------------------------------------------------- UNITS--------------------------------

    function __amountPerc(uint _amount) private pure returns(uint){
        return _amount * (10 ** 3);
    }

    function __amount(uint _amount) private pure returns(uint){
        return _amount * (10 ** 18);
    }
    
   
    function __unAmount(uint256 _amount, uint decimals) private pure returns(uint){
        return _amount / (10 ** decimals);
    }

    
    // ------------------------------- STRUCTS ---------------------------------

    struct cliente {
        uint tokens_comprados;
        uint total_products;
        // Producto[] Purchases;
        Contrato[] contratos;
        string[] NameProducts;
        uint[] MapProducts;
        uint[] MapContracts;
    }

    struct Producto {
        uint256 idProduct;
        string name;
        string desc;
        string section;
        uint price;
        uint cycle;
        uint percAttMin;
        uint percAttMax;
        bool availability;
        string image;
        uint256 createdAt;
    }

     struct Contrato { 
        uint256 contractid;
        uint256 productid;
        string nameProduct;
        uint256 percAttMin;
        uint256 percAttMax;
        uint256 amount;
        uint256 productPrice;
        uint256 totalPrice;
        uint256 cycle;
        address customer;
        bool existencia;
        uint256 creationDate;
        
    }

    //-------------------------------- EVENTOS ----------------------
    
    event ProductoAgregado(
        uint256 idProduct,
        string name,
        string desc,
        string section,
        uint price,
        uint cycle,
        uint percAttMin,
        uint percAttMax,
        bool availability,
        string image, 
        uint256 createdAt
    );

    event DisponibilidadAlternada(uint256 idProduct, bool availability);

    event ProductoComprado(uint256 id, uint PrecioTokens, address indexed cliente);

    event contratoCreado(
        uint256 contractid,
        uint256 productid,
        string nameProduct,
        uint256 percAttMin,
        uint256 percAttMax,
        uint256 amount,
        uint256 productPrice,
        uint256 totalPrice,
        uint256 cycle,
        address customer,
        bool existencia,
        uint256 creationDate
    );

    event OtorgandoPorcentajeRendimiento(uint id, address customer,uint256 rendimiento);
    
    event TokensDevueltos(uint,address);

    //----------------------------------------- MAPPINGs Y ARRAYs ---------------------------------

    uint256 [] Productos; 
    mapping (address => uint256 []) public HistorialProductos;

    mapping (uint256 => Producto) public MappingProductos;  
    mapping (address => cliente) public  MappingClientes;  
    mapping (uint256 => Contrato) public MappingContratos;



    function CrearProducto(
        uint256 _id, 
        string memory _nombreProducto, 
        string memory _descripcion,
        string memory _seccion, 
        uint _precioTokens,
        uint _DiasCiclo,
        uint _PercAttMin,
        uint _PercAttMax,
        string memory _imageProduct
        ) external Unicamente (msg.sender) {  
                
        if(MappingProductos[_id].availability == false)
        {  
           
           MappingProductos[_id] = Producto (_id, _nombreProducto, _descripcion, _seccion, __amount(_precioTokens), _DiasCiclo, _PercAttMin, _PercAttMax, true,_imageProduct,  block.timestamp);
           MapProducts.push(Producto(_id, _nombreProducto, _descripcion, _seccion, __amount(_precioTokens), _DiasCiclo,  _PercAttMin, _PercAttMax, true, _imageProduct, block.timestamp));
           Productos.push(_id);
           productsCounter += 1;
           
        }

        Producto storage _producto = MapProducts[_id];
        _producto.name = _nombreProducto;
        _producto.desc = _descripcion;
        _producto.section = _seccion;
        _producto.price = __amount(_precioTokens);
        _producto.cycle = _DiasCiclo;
        _producto.percAttMin = _PercAttMin;
        _producto.percAttMax = _PercAttMax;
        _producto.image = _imageProduct;
        MapProducts[_id] = _producto;

        MappingProductos[_id] = Producto (_id, _nombreProducto, _descripcion, _seccion, __amount(_precioTokens), _DiasCiclo, _PercAttMin, _PercAttMax, true, _imageProduct, block.timestamp);

       
            
        emit ProductoAgregado(_id, _nombreProducto, _descripcion, _seccion, __amount(_precioTokens), _DiasCiclo, _PercAttMin, _PercAttMax, true, _imageProduct, block.timestamp);
    }

    function BajaProducto (uint256 _id) public Unicamente(msg.sender){
        Producto memory _producto = MappingProductos[_id];
        _producto.availability = !_producto.availability;
        MappingProductos[_id] = _producto;

        emit DisponibilidadAlternada(_id, _producto.availability);
     }

    function ComprarProducto (uint256 _id, uint _Cantidad) public {
        uint CostoTotal = _Cantidad*MappingProductos[_id].price;
        require (MappingProductos[_id].availability == true, "id del producto no disponible.");
        require(CostoTotal <= CustomerTokens(msg.sender), "Necesitas mas Tokens para comprar este producto.");
        token.transferencia_SDV(msg.sender, address(this),CostoTotal);
        string storage _nameProduct = MappingProductos[_id].name;
        cliente storage buyer = MappingClientes[msg.sender];
        buyer.total_products += 1*_Cantidad;
        buyer.MapProducts.push(_id);
        buyer.NameProducts.push(_nameProduct);
        HistorialProductos[msg.sender].push(_id);

        if(true)
        {  
            contractsCounter += 1;
            uint idContract = contractsCounter - 1;
            uint cycle = MappingProductos[_id].cycle;
            
            MappingContratos[idContract] = Contrato (idContract, _id, _nameProduct, MappingProductos[_id].percAttMin, MappingProductos[_id].percAttMax, _Cantidad, MappingProductos[_id].price, CostoTotal, cycle, msg.sender, true, block.timestamp);
            MapContracts.push(Contrato (idContract, _id, _nameProduct, MappingProductos[_id].percAttMin, MappingProductos[_id].percAttMax, _Cantidad, MappingProductos[_id].price, CostoTotal, cycle, msg.sender, true, block.timestamp));
            buyer.contratos.push(Contrato (idContract, _id, _nameProduct, MappingProductos[_id].percAttMin, MappingProductos[_id].percAttMax, _Cantidad, MappingProductos[_id].price, CostoTotal, cycle, msg.sender, true, block.timestamp));
            buyer.MapContracts.push(idContract);

            emit contratoCreado(idContract, _id, _nameProduct, MappingProductos[_id].percAttMin,  MappingProductos[_id].percAttMax, _Cantidad, MappingProductos[_id].price, CostoTotal, cycle, msg.sender, true, block.timestamp);
           
        }

        emit ProductoComprado(_id, CostoTotal, msg.sender);
    }

    

        
    function OtorgarRendimiento(uint256 _idContract, uint _porcentajeRendimiento) public Unicamente(msg.sender) {
        require (MappingContratos[_idContract].existencia == true, "Id de contrato no disponible" );
        
        if (true) {

            require (MappingContratos[_idContract].percAttMin <= _porcentajeRendimiento, "Este porcentaje es inferior al minimo requerido");
            require (MappingContratos[_idContract].percAttMax >= _porcentajeRendimiento, "Este porcentaje es superior al porcentaje maximo permitido");

            uint Balance = TokensDisponibles();
            uint Rendimiento = MappingContratos[_idContract].totalPrice + (MappingContratos[_idContract].totalPrice / 100)*(_porcentajeRendimiento / 100);
            require(Rendimiento <= Balance, "No hay suficientes tokens para otorgar");    
            address CustomerAddress = MappingContratos[_idContract].customer;    
            token.transfer(CustomerAddress, Rendimiento);
            
            Contrato memory _contrato = MappingContratos[_idContract];
            _contrato.existencia = !_contrato.existencia;
            MappingContratos[_idContract] = _contrato;

            Contrato memory _contract = MapContracts[_idContract];
            _contract.existencia = !_contract.existencia;
            MapContracts[_idContract]= _contract;
            
            emit OtorgandoPorcentajeRendimiento(_idContract, CustomerAddress, Rendimiento);

        }     
    }

     function getProduct(uint product_id) external view returns (Producto memory){
        return MapProducts[product_id];
    }

    function getProducts() public view returns (Producto[] memory){
        return MapProducts;
    }

    function getUser(address userAddress) external view returns (cliente memory){
        return MappingClientes[userAddress];
    }

    function getContractById(uint contract_id) public view returns (Contrato memory){
        return MapContracts[contract_id];
    }

    function getContracts() public view returns (Contrato[] memory){
        return MapContracts;
    }

    // function HistorialDeProductos() public view returns (uint256 [] memory) {
    //     return HistorialProductos[msg.sender];
    // }

    function totalProducts() public view returns(uint){
        return productsCounter;
    }

    function totalContracts() public view returns(uint){
        return contractsCounter;
    }

    function ProductosDisponibles() public view returns (uint [] memory){
        return Productos;
    }

    
    function DevolverTokens (uint _numTokens) public payable {
        require (_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens.");
        require (__amount(_numTokens) <= CustomerTokens(msg.sender), "No tienes los tokens que deseas devolver.");
         token.transferencia_SDV(msg.sender, address(this),__amount(_numTokens));
         msg.sender.transfer(tokenPrice*(_numTokens));
         emit TokensDevueltos( _numTokens, msg. sender);
    }

    function withdraw() external payable Unicamente (msg.sender) {
        msg.sender.transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;


// Implementacion de la libreria SafeMath para realizar las operaciones de manera segura
// Fuente: "https://gist.github.com/giladHaimov/8e81dbde10c9aeff69a1d683ed6870be"

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf (address account) external view returns (uint256);
    function allowance(address owner,address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferencia_SDV(address sender, address recipient, uint256 amount) external returns (bool);
    function approve (address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
}

contract ERC20LuumIn is IERC20 {
    string public constant name = "LUUM IN";
    string public constant symbol = "LUUM";
    uint256 public constant decimals = 18;
    uint256 private totalSupply_;
    address private _owner;

    modifier onlyOwner{
         require(msg.sender == _owner, "Only the owner can execute this function.");
         _;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    mapping (address => uint256) balances;
    mapping(address => mapping (address => uint)) allowed;
    
    using SafeMath for uint256;
    
    constructor (uint256 total) public{
        totalSupply_ = total * 10 ** decimals;
        balances[msg.sender] = totalSupply_;
        _owner = msg.sender;

        emit Transfer(address(0),msg.sender, totalSupply_);
    }
    
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    
    function increaseTotalSuply(uint newTokens) public{
        totalSupply_ += newTokens;
        balances[msg.sender] += newTokens;
    }
    
    function balanceOf (address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender,receiver,numTokens);
        return true;
    } 
    
    function transferencia_SDV(address sender, address receiver, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[sender]);
        balances[sender] = balances[sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(sender,receiver,numTokens);
        return true;
    } 
    
    function approve (address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance (address owner, address delegate) public override view returns (uint){
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require (numTokens <= balances[owner]);
        require (numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner,buyer,numTokens);
        return true;
    }

    function mint (uint256 value) public onlyOwner returns (bool) {
        require(msg.sender == _owner, "Only owner can mint new tokens");
        uint256 amount = value * 10 ** 18;
        totalSupply_ += amount;
        balances[_owner] += amount;
        emit Transfer(address(0), _owner, amount);
        return true;
    }

     function _burn(uint256 value) internal onlyOwner returns (bool) {
      uint256 amount = value * 10 ** 18;
      require(balances[_owner] >= amount,"amount exceeded" );
      totalSupply_ = totalSupply_.sub(amount);
      balances[_owner] = balances[_owner].sub(amount);
      emit Burn(msg.sender, amount);
      return true;
    }

    function burn(uint256 amount) public {
        _burn(amount);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        balances[_newOwner] = balances[_owner];
        balances[_owner] = 0;
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
     }
    
}