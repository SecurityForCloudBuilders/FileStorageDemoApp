Esse guia dá o passo-a-passo para realizar um deploy serverless dessa aplicação, acessível via a internet. Usaremos:

- IAM 
- AWS ECR
- AWS ECS Fargate 
- VPC Pública 

Esse guia assume que você esteja familiarizado com AWS, tenha criado um bucket S3 para testar a aplicação e tenha o AWS CLI instalado. 

# Clone o Repositório do código fonte

`git clone https://github.com/SecurityForCloudBuilders/FileStorageDemoApp.git`

# 1. Crie um Repositório
`ECR > Repositories > Create Repository`

Escolha um nome. As configurações padrão são aceitáveis.

O repositório pode ser privado ou público. Para princípios desse guia, **vamos seguir assumindo um repositório privado.** 

# 2. Preparar a imagem
(Obs: Será necessário ter o AWS CLI instalado e configurado para esse passo.)

Na tela do repositório, clique em `view push commands`. 

Siga as instruções na tela. Elas mostram como obter os tokens de autenticação para realizar o `push` da imagem para seu repositório ECR. 

A imagem agora está pronta para uso. 

# 3. (Opcional) (Re)Crie um IAM Role com as permissões

O IAM Role `ecsTaskExecutionRole` gerenciado pela AWS provê as permissões que necessitamos. Ele utiliza uma única policy chamada `AmazonECSTaskExecutionRolePolicy`

Caso a role e/ou a policy não existam, [siga esse guia para criar novos](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)

# 4. Crie uma Task Definition
## Launch Type: `Fargate`
Selecione `Fargate` - a infraestrutura subjacente é gerenciada pela AWS e podemos focar na aplicação. 

## Task Definitions
Aqui é onde faremos a configuração propriamente dita. 
* Em `Task Role` e `Task execution role` adicione o `ecsTaskExecutionRole`
    * Caso esse Role não exista, ou ocorra algum erro de permissões, verifique o passo 3
* Em `Task Size` configure a memória e CPU necessários. **0.5GB e 0.25vCPUs serão suficientes** para o Coffeeshop

### Container Definitions
* Container Name: Escolha um nome
* Image: Coloque a **URI e tag do repositório** que criamos no passo 1
* Port Mapping: Adicione um Port mapping com a porta `8080` e protocolo `tcp`
* Em `Advanced container configuration > Environment` adicione as quatro variáveis de ambiente com seus respectivos valores, como no README. 
    * `AWS_ACCESS_KEY_ID`
    * `AWS_SECRET_ACCESS_KEY`
    * `BUCKET_NAME`
    * `BUCKET_REGION`
    * **_(!) IMPORANTE (!)_** Adicionar credenciais de acesso em texto-plano como feito aqui, é uma má-prática de segurança. Ela será utilizada por simplicidade e pela natureza dessa aplicação (testes/prova de conceito). Nunca faça isso em um contexto real.


# 5. Crie um ECS Cluster
`ECS > Clusters > Create Cluster`
* Em `Template` Selecione `Networking Only (Powered by AWS Fargate)`
* Adicione um nome para o Cluster.
    * Você pode criar uma VPC pública se já não tiver uma.

# 6. Rodando
Em `ECS > Clusters` Selecione o Cluster que você criou

`Tasks > Run new Task` 
* Selecione o Launch Type como `Fargate`
* Selecione a Task definition que você configurou
* Selecione uma VPC e sub-net acessíveis publicamente. Selecione ou crie um Security Group que autorize tráfego TCP na porta 8080
* Libere auto-assign public-IP
* Se necessário, **você pode alterar os valores das variáveis de ambiente** em `Advanced Options > Container Overrides`
* Clique em `Run Task`

Na Lista de Tasks, selecione a task recém-criada. Sob network, está o IP público do seu container. Acesse o container do seu browser. `ip:8080`  

# 7. Parando
Na Lista de Tasks, selecione a task recém-criada. Clique em `Stop`
