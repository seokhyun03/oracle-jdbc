<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	// 현재페이지
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	// oracle db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	// 전체 행의 수 구하는 sql
	PreparedStatement totalRowStmt = null;
	ResultSet totalRowRs = null;
	String totalRowSql = "select count(*) from employees";
	totalRowStmt = conn.prepareStatement(totalRowSql);
	totalRowRs = totalRowStmt.executeQuery();
	// 페이지 당 행의 수
	int rowPerPage = 10;
	// 시작 행 번호
	int beginRow = (currentPage-1) * rowPerPage + 1;
	// 마지막 행 번호
	int endRow = beginRow + rowPerPage - 1;
	// 전체 행의 수
	int totalRow = 0;
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	// 마지막 행 번호 > 전체 행의 수 -> 마지막 행 번호 = 전체 행의 수
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	// 마지막 페이지 번호
	int lastPage = totalRow / rowPerPage;
	// 표시하지 못한 행이 있을 경우 페이지 + 1
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	
	// exists sql 전송
	String existsSql = "select 번호, 사원ID, 이름, 부서ID from (select rownum 번호, 사원ID, 이름, 부서ID from (select e.employee_id 사원ID, e.first_name 이름, e.department_id 부서ID from employees e where exists (select * from departments d where d.department_id = e.department_id))) where 번호 between ? and ?";
	PreparedStatement existsStmt = conn.prepareStatement(existsSql);
	existsStmt.setInt(1,beginRow);
	existsStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(existsStmt + " <-- exists_not_exists_list existsStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet existsRs = existsStmt.executeQuery();
	ArrayList<HashMap<String, Object>> existsList = new ArrayList<HashMap<String, Object>>();
	while(existsRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", existsRs.getString("번호"));
		m.put("사원ID", existsRs.getString("사원ID"));
		m.put("이름", existsRs.getString("이름"));
		m.put("부서ID", existsRs.getString("부서ID"));
		existsList.add(m);
	}
	// not_exists sql 전송 
	String not_existsSql = "select 번호, 사원ID, 이름, 부서ID from (select rownum 번호, 사원ID, 이름, 부서ID from (select e.employee_id 사원ID, e.first_name 이름, e.department_id 부서ID from employees e where not exists (select * from departments d where d.department_id = e.department_id)))";
	PreparedStatement not_existsStmt = conn.prepareStatement(not_existsSql);
	// 위 sql 디버깅
	System.out.println(not_existsStmt + " <-- exists_not_exists_list not_existsStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet not_existsRs = not_existsStmt.executeQuery();
	ArrayList<HashMap<String, Object>> not_existsList = new ArrayList<HashMap<String, Object>>();
	while(not_existsRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", not_existsRs.getString("번호"));
		m.put("사원ID", not_existsRs.getString("사원ID"));
		m.put("이름", not_existsRs.getString("이름"));
		m.put("부서ID", not_existsRs.getString("부서ID"));
		not_existsList.add(m);
	}	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="row">
	<div class="col-sm">
		<h1>exists</h1>
		<table class="table">
			<tr>
				<td>사원ID</td>
				<td>이름</td>
				<td>부서ID</td>
			</tr>
			<%
				for(HashMap<String, Object> m : existsList) {
			%>
					<tr>
						<td><%=m.get("사원ID")%></td>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("부서ID")%></td>
					</tr>
			<%	
				}
			%>
		</table>
	</div>
	<div class="col-sm">
		<h1>not_exists</h1>
		<table class="table">
			<tr>
				<td>사원ID</td>
				<td>이름</td>
				<td>부서ID</td>
			</tr>
			<%
				for(HashMap<String, Object> m : not_existsList) {
			%>
					<tr>
						<td><%=m.get("사원ID")%></td>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("부서ID")%></td>
					</tr>
			<%	
				}
			%>
		</table>
	</div>
</div>
<%
	// 페이징 수
	int pagePerPage = 10;
	// 최소 페이지
	int minPage = (currentPage-1) / pagePerPage * pagePerPage + 1;
	// 최대 페이지
	int maxPage = minPage + pagePerPage - 1;
	// 최대 페이지가 마지막 페이지 보다 크면 최대 페이지 = 마지막 페이지
	if(maxPage > lastPage) {
		maxPage = lastPage;
	}
	// 이전 페이지
	// 최소 페이지가 1보타 클 경우 이전 페이지 표시
	if(minPage>1) {
%>
		<a href="<%=request.getContextPath()%>/exists_not_exists.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
<%			
	}
	// 최소 페이지부터 최대 페이지까지 표시
	for(int i = minPage; i<=maxPage; i=i+1) {
		if(i == currentPage) {	// 현재페이지는 링크 비활성화
%>	
		<%=i%>
<%			
		}else {					// 현재페이지가 아닌 페이지는 링크 활성화
%>	
			<a href="<%=request.getContextPath()%>/exists_not_exists.jsp?currentPage=<%=i%>"><%=i%></a>
<%				
		}
	}
	// 다음 페이지
	// 최대 페이지가 마지막 페이지와 다를 경우 다음 페이지 표시
	if(maxPage != lastPage) {
%>
		<a href="<%=request.getContextPath()%>/exists_not_exists.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
<%	
	}
%>
</body>
</html>