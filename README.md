# Persifix

## Visão Geral do Projeto
Persifix é uma aplicação web projetada para gerenciamento de vendas e orçamentos de persianas e acessórios. Ele oferece uma interface moderna e amigável para otimizar o processo de vendas, desde a criação de orçamentos até o acompanhamento de clientes e relatórios de vendas.

## Funcionalidades
- Cadastro e gerenciamento de produtos (persianas e acessórios)
- Cadastro e gerenciamento de clientes
- Criação e acompanhamento de orçamentos
- Agendamento de visitas
- Geração de relatórios de vendas
- Configurações personalizadas (métodos de pagamento, etc.)
- Sincronização de dados online/offline

## Tecnologias Utilizadas
- **Frontend:** React, Vite, JavaScript
- **Backend:** Supabase (autenticação, banco de dados PostgreSQL, storage)
- **Estilização:** CSS puro
- **Componentes UI:** Componentes customizados
- **Gráficos:** Chart.js
- **Geração de PDF:** jsPDF, html2canvas

## Configuração do Ambiente de Desenvolvimento
1. **Clone o repositório:**
   ```bash
   git clone <url-do-repositorio-persifix>
   ```
2. **Navegue até o diretório do projeto:**
   ```bash
   cd persifix
   ```
3. **Instale as dependências:**
   ```bash
   npm install
   ```
4. **Configuração do Supabase:**
   - Crie um projeto no [Supabase](https://supabase.com/).
   - No diretório raiz do projeto, crie um arquivo `.env` (ou renomeie `.env.example` para `.env` se existir).
   - Adicione as seguintes variáveis de ambiente ao arquivo `.env` com as credenciais do seu projeto Supabase:
     ```
     VITE_SUPABASE_URL=SUA_SUPABASE_URL
     VITE_SUPABASE_ANON_KEY=SUA_SUPABASE_ANON_KEY
     ```
   - Execute os scripts SQL localizados na pasta `supabase/migrations/` para criar as tabelas e configurar o banco de dados. Você pode usar o editor SQL do Supabase ou uma ferramenta de banco de dados de sua preferência. Comece pelos arquivos de criação de tabelas (`create_*.sql`) e depois os de correção/alteração.

5. **Inicie o servidor de desenvolvimento:**
   ```bash
   npm run dev
   ```
   A aplicação estará acessível em `http://localhost:5173` (ou outra porta, se especificado pelo Vite).

## Uso
Após iniciar o servidor de desenvolvimento, acesse a interface web através do seu navegador no endereço fornecido.
- **Login:** Utilize as credenciais de um usuário cadastrado no Supabase Auth.
- **Navegação:** Utilize o menu lateral para acessar as diferentes seções da aplicação (Dashboard, Orçamentos, Clientes, Produtos, etc.).

## Scripts SQL Importantes
A pasta `supabase/` contém diversos scripts SQL:
- `migrations/`: Contém as migrações do banco de dados, incluindo criação de tabelas, adição de colunas e políticas de segurança (Row Level Security - RLS).
- Outros arquivos `.sql` na raiz de `supabase/`: Scripts para correções específicas, configuração inicial de dados (como `setup_configuracoes.sql`), etc.

**Ordem sugerida para execução dos scripts de migração (após criar o projeto no Supabase):**
1. Scripts de criação de tabelas (ex: `create_sellers_table.sql`, `create_produtos_table.sql`, `create_medidas_table.sql`, etc.).
2. Scripts de alteração e adição de funcionalidades (ex: `20240223_add_valor_negociado.sql`, `20250223_create_accessories_table.sql`, etc.).
3. Scripts de políticas (ex: `fix_policies.sql`, `fix_profile_policies.sql`).
4. Scripts de configuração inicial (ex: `supabase/setup_configuracoes.sql`).

## Implantação (Deploy) no Cloudflare Pages

### Configuração Manual
1. Acesse o [Dashboard do Cloudflare Pages](https://dash.cloudflare.com) e crie um novo projeto.
2. Conecte seu repositório Git.
3. Configure as seguintes opções de build:
   - **Comando de build:** `npm run build`
   - **Diretório de saída do build:** `dist`
   - **Versão do Node.js:** `18.x` (ou superior)
   - **Variáveis de Ambiente:** Configure as mesmas variáveis `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` nas configurações do ambiente do Cloudflare Pages.

### Solução de Problemas de Roteamento SPA
O projeto já inclui configurações para garantir que o roteamento SPA funcione corretamente no Cloudflare Pages:
- Arquivo `_redirects` na pasta `public` para redirecionamento de rotas.
- Arquivo `_routes.json` para configuração de rotas no Cloudflare.
- Configurações no `index.html` para evitar problemas com `lockdown-install.js` do Cloudflare.
- Configuração de chunking no `vite.config.js` para melhor performance.

Se você encontrar problemas com "Removing unpermitted intrinsics lockdown-install.js", verifique se:
- O arquivo `public/lockdown-no-op.js` está incluído no build.
- Os scripts de inicialização de segurança foram adicionados ao `index.html`.

## Contribuições
Contribuições são bem-vindas! Por favor, siga estes passos:
1. Faça um fork do repositório.
2. Crie uma nova branch para sua feature ou correção de bug (`git checkout -b minha-feature`).
3. Faça commit das suas alterações (`git commit -m 'Adiciona nova feature'`).
4. Faça push para a branch (`git push origin minha-feature`).
5. Abra um Pull Request com uma descrição detalhada das suas alterações.

## Estrutura do Projeto (Simplificada)
```
persifix/
├── public/               # Arquivos estáticos e configurações de deploy
├── src/
│   ├── assets/           # Imagens, fontes, etc. (se houver)
│   ├── components/       # Componentes React reutilizáveis
│   ├── config/           # Configurações específicas da aplicação (ex: users.json)
│   ├── pages/            # Componentes de página (se usar essa estrutura)
│   ├── services/         # Lógica de negócios, chamadas API, serviços
│   ├── supabase/         # Configuração do cliente Supabase
│   ├── App.jsx           # Componente principal da aplicação
│   ├── main.jsx          # Ponto de entrada da aplicação React
│   └── index.css         # Estilos globais
├── supabase/             # Scripts SQL, migrações, políticas para o Supabase
├── .gitignore
├── build.gradle.kts      # (Parece ser um resquício de um projeto Android/Kotlin, verificar necessidade)
├── index.html            # HTML principal
├── netlify.toml          # (Configuração para Netlify, verificar se ainda é usado)
├── package.json          # Dependências e scripts do projeto
├── vite.config.js        # Configurações do Vite
└── README.md             # Este arquivo
```

## Observações Adicionais
- O projeto parece conter alguns arquivos de configuração (`build.gradle.kts`, `netlify.toml`, `local.properties`) que podem não ser relevantes para uma aplicação web React/Vite pura. É recomendável verificar se são necessários ou se podem ser removidos para simplificar o projeto.
- A pasta `Persifix/` dentro do repositório parece ser uma duplicata ou uma versão antiga do projeto. Isso deve ser investigado e limpo se necessário.

Este README fornece um guia completo para entender, configurar e contribuir com o projeto Persifix.
